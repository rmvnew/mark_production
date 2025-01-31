
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("mark_production", src)
Proxy.addInterface("mark_production", src)
vCLIENT = Tunnel.getInterface("mark_production")

ORG_NAME = nil

vRP.prepare('vRP/getUserOrgByUserId', [[
  SELECT org
  FROM dani_orgs
  WHERE JSON_VALUE(membros, CONCAT('$.', @user_id, '.groupPrefix')) IS NOT NULL;
]])


function vRP.getUserOrgName(user_id)
    local rows = vRP.query('vRP/getUserOrgByUserId', { user_id = user_id })
    if #rows > 0 then
        return rows[1].org or "Sem Organização"
    end
    return "Sem Organização"
end


RegisterNetEvent("mark_production:checkPermission")
AddEventHandler("mark_production:checkPermission",function ()
    
    local source = source
    local user_id = vRP.getUserId(source)
    
    -- ORG_NAME = args[1]
    ORG_NAME = vRP.getUserOrgName(user_id)

   
    
    local permissionTable = exports.oxmysql:query_async('SELECT permission FROM facs_produced WHERE org = ?',{ORG_NAME})
    
    if permissionTable[1].permission and #permissionTable[1].permission > 0 then
       
        local permission = permissionTable[1].permission
       
        if vRP.hasPermission(user_id,permission) then
            print("Tem permissao")
            local dataResponse = getData()
            
            if dataResponse then
                TriggerClientEvent("mark_production:openNUI", source, dataResponse)
            else
                print("Erro ao buscar dados para org: " .. ORG_NAME)
                TriggerClientEvent("Notify", source, "negado", "Erro ao buscar dados da organização.", 10)
            end
        else
            print("Não Tem permissao")
            TriggerClientEvent("mark_production:closeNUI",source)
            TriggerClientEvent("Notify",source,"negado","Você não tem permissão para acessar este serviço",10)
        end


    end


end)


function getData()
    
    local query = "SELECT produced FROM facs_produced WHERE org = ?"
    local result = exports.oxmysql:query_async(query, { ORG_NAME })

    if result and #result > 0 then
        return json.decode(result[1].produced)
    end
    return nil
   

end




RegisterNetEvent("mark_production:getItem")
AddEventHandler("mark_production:getItem", function(current_item)

    local source = source 
    local user_id = vRP.getUserId(source)

    -- Decodificar o JSON recebido em uma tabela Lua
    local data_by_list = json.decode(current_item)
    -- print("Item recebido:", json.encode(data_by_list))
    -- print(data_by_list.item)
    -- print(data_by_list.quantidade)

    local dataResponse = getData() -- Supondo que esta função retorne uma tabela
    -- print("Lista atual:", json.encode(dataResponse))


    -- Localizar o índice do item na tabela
    local itemIndex = nil
    for index, value in ipairs(dataResponse) do
        if value.item == data_by_list.item and value.quantidade == data_by_list.quantidade then
            itemIndex = index
            break
        end
    end

    
    if itemIndex then
        vRP.giveInventoryItem(user_id, data_by_list.item, data_by_list.quantidade, true)
        table.remove(dataResponse, itemIndex)

        TriggerClientEvent("Notify",source,"sucesso","Você coletou o item "..data_by_list.item.." na quantidade "..data_by_list.quantidade)
        TriggerClientEvent("mark_production:alertSuccess",source)
    else
        print("Item não encontrado na lista!")
    end

    local newList = json.encode(dataResponse)
    -- Exibir a lista atualizada
    -- print("Lista atualizada:",newList )

    local current_query = "UPDATE facs_produced SET produced = ? WHERE org = ?"
    exports.oxmysql:update_async(current_query,{newList,ORG_NAME})

    
    SetTimeout(1000,function()
        
        local newDataResponse = getData()
                
        if newDataResponse then
            TriggerClientEvent("mark_production:openNUI", source, newDataResponse)
        else
            print("Erro ao buscar novos dados para org: " .. ORG_NAME)
            TriggerClientEvent("Notify", source, "negado", "Erro ao buscar dados da organização.", 10)
        end

    end)

    

end)




RegisterCommand('myquery',function (source)


    local obter = "SELECT produced FROM facs_produced WHERE org = ?"
    local data = exports.oxmysql:query_async(obter, {'Bahamas'})
    
    if data and #data > 0 then -- Verifica se há resultados
        -- Decodifica o campo 'produced' (que está no formato JSON) em uma tabela
        local dataRes = json.decode(data[1].produced)
    
        if type(dataRes) ~= "table" then
            dataRes = {} -- Garante que seja uma tabela, caso esteja vazio ou inválido
        end
    
        local novoItem = {
            quantidade = 10,
            item = "cafe_puro"
        }
    
        -- Adiciona o novo item à tabela
        table.insert(dataRes, novoItem)
    
        -- Opcional: Codifica novamente para JSON, caso precise salvar ou enviar de volta
        local dataResJson = json.encode(dataRes)
    
        print("Tabela atualizada com o novo item:")
        print(dataResJson) -- Exibe a tabela atualizada
    else
        print("Nenhum dado encontrado.")
    end
    
    
    
    -- local current_query = "UPDATE facs_produced SET produced = ? WHERE org = ?"

    -- local itens = json.encode({item = 'cafe_com_leite',quantidade = 5})


    -- exports.oxmysql:update_async(current_query,{itens,'Bahamas'})

end,false)