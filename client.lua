local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","mark_production")
src = {}
Tunnel.bindInterface("mark_production",src)
vSERVER = Tunnel.getInterface("mark_production")


RegisterCommand('prod',function ()

    TriggerServerEvent("mark_production:checkPermission")
    
end)

RegisterNetEvent("mark_production:alertSuccess")
AddEventHandler("mark_production:alertSuccess",function(source)

    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

end)

-- abrir BUI se tiver permissao
RegisterNetEvent("mark_production:openNUI")
AddEventHandler("mark_production:openNUI",function (dataResponse)
   
    if dataResponse then
        print("Dados recebidos no cliente: " .. json.encode(dataResponse))
        SendNUIMessage({ dataResponse = dataResponse, hasPermission = 'open' })
        SetNuiFocus(true, true)
    else
        print("Erro: Nenhum dado recebido para abrir NUI")
        TriggerEvent("Notify", "negado", "Erro ao carregar os dados.", 10)
    end

end)

-- fecha se não tem permissao
RegisterNetEvent("mark_production:closeNUI")
AddEventHandler("mark_production:closeNUI", function()

    SetNuiFocus(false,false)
    SendNUIMessage({hasPermission = 'closed'})

end)

-- fecha com ESC
RegisterNUICallback("closeCurrentNUI",function(data,cb)
    SetNuiFocus(false,false)
    SendNUIMessage({hasPermission = 'closed'})
    if cb then cb('ok') end
end)


RegisterNUICallback("getItem",function (item)
   
    local current_item = json.encode(item)
    
    TriggerServerEvent("mark_production:getItem",current_item)

end)