
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("mark_production", src)
Proxy.addInterface("mark_production", src)
vCLIENT = Tunnel.getInterface("mark_production")
local cfg = module("vrp", "cfg/groups")

ORG_NAME = nil


function getUserOrganization(user_id)
    if not user_id then return nil end

    -- 1) Ler do banco o vRP:datatable
    local data = vRP.getUData(user_id, "vRP:datatable")
    if not data or data == "" then
        return nil
    end

    -- 2) Decodifica o JSON
    local datatable = json.decode(data)
    if not datatable or not datatable.groups then
        return nil
    end

    -- 3) Percorre todos os grupos do player
    for groupName, _ in pairs(datatable.groups) do
        local groupInfo = cfg.groups[groupName]
        -- Verifica se esse grupo existe no cfg.groups e tem gtype = "org"
        if groupInfo and groupInfo._config and groupInfo._config.gtype == "org" then
            -- Retorna o orgName imediatamente
            return groupInfo._config.orgName
        end
    end

    return nil
end



RegisterNetEvent("mark_production:checkPermission")
AddEventHandler("mark_production:checkPermission",function ()
    
    local source = source
    local user_id = vRP.getUserId(source)
    
    -- ORG_NAME = args[1]
    ORG_NAME = getUserOrganization(user_id)

    
   if ORG_NAME ~= nil then
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
                TriggerClientEvent("mark_production:unauthorized",source)
            end

        else
            TriggerClientEvent("Notify",source,"negado","Deposito não encontrado",10)
        end
   else
    TriggerClientEvent("mark_production:unauthorized",source)
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




