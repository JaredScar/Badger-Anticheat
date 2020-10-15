local ProhibitedVariables = Config.BlacklistedVariables
function CheckVariables()
    for i, v in pairs(ProhibitedVariables) do
        if _G[v] ~= nil then
            TriggerServerEvent('Anticheat:Modder', 'Mod Menu Injected Code: ' .. v, 'Injected code you are banned goodbye!')
        end
    end
end

function BanAllPlayers() 
end

if Config.Components.ModMenuChecks then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000)
            CheckVariables()
        end
    end)
end
