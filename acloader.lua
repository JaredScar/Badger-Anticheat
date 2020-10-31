local ProhibitedVariables = { -- Add as many as you want from mod menus you find! (Remove war menu if you use it!)
"fESX", "Plane", "TiagoMenu", "Outcasts666", "dexMenu", "Cience", "LynxEvo", "zzzt", "AKTeam",
"gaybuild", "ariesMenu", "WarMenu", "SwagMenu", "Dopamine", "Gatekeeper", "MIOddhwuie"
}
local Enabled = false -- Change this to enable client mod menu checks!
function CheckVariables()
    for i, v in pairs(ProhibitedVariables) do
        if _G[v] ~= nil then
            TriggerServerEvent('Anticheat:Modder', 'Mod Menu Injected Code: ' .. v, 'Injected code you are banned goodbye!')
        end
    end
end

if Enabled then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000)
            CheckVariables()
        end
    end)
else
    return "Nil"
end
