
-- prevent infinite ammo, godmode, invisibility and ped speed hacks 
-- Props to Anticheese Anticheat for this: [https://github.com/Bluethefurry]
if Config.Components.Anticheat then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)
            SetPedInfiniteAmmoClip(PlayerPedId(), false)
            SetEntityInvincible(PlayerPedId(), false)
            SetEntityCanBeDamaged(PlayerPedId(), true)
            ResetEntityAlpha(PlayerPedId())
            local fallin = IsPedFalling(PlayerPedId())
            local ragg = IsPedRagdoll(PlayerPedId())
            local parac = GetPedParachuteState(PlayerPedId())
            if parac >= 0 or ragg or fallin then
                SetEntityMaxSpeed(PlayerPedId(), 80.0)
            else
                SetEntityMaxSpeed(PlayerPedId(), 7.1)
            end
        end
    end)
end
-- End props 
teleported = false;
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0);
        if (IsControlJustPressed(0, 18)) then 
            teleported = true;
            Wait(1000);
            teleported = false;
        end
    end 
end)
--[[]]--
-- Props to Anticheese Anticheat for this: [https://github.com/Bluethefurry]
if Config.Components.AntiSpeedhack then
    Citizen.CreateThread(function()
        Citizen.Wait(30000)
        while true do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            local posx,posy,posz = table.unpack(GetEntityCoords(ped,true))
            local still = IsPedStill(ped)
            local vel = GetEntitySpeed(ped)
            local ped = PlayerPedId()
            local veh = IsPedInAnyVehicle(ped, true)
            local speed = GetEntitySpeed(ped)
            local para = GetPedParachuteState(ped)
            local flyveh = IsPedInFlyingVehicle(ped)
            local rag = IsPedRagdoll(ped)
            local fall = IsPedFalling(ped)
            local parafall = IsPedInParachuteFreeFall(ped)
            SetEntityVisible(PlayerPedId(), true) -- make sure player is visible
            Wait(3000) -- wait 3 seconds and check again

            local more = speed - 9.0 -- avarage running speed is 7.06 so just incase someone runs a bit faster it wont trigger

            local rounds = tonumber(string.format("%.2f", speed))
            local roundm = tonumber(string.format("%.2f", more))


            if not IsEntityVisible(PlayerPedId()) then
                SetEntityHealth(PlayerPedId(), -100) -- if player is invisible kill him!
            end

            newx,newy,newz = table.unpack(GetEntityCoords(ped,true))
            newPed = PlayerPedId() -- make sure the peds are still the same, otherwise the player probably respawned
            if not teleported and GetDistanceBetweenCoords(posx,posy,posz, newx,newy,newz) > 200 and still == IsPedStill(ped) and vel == GetEntitySpeed(ped) and ped == newPed then
                TriggerServerEvent("Anticheat:NoClip", GetDistanceBetweenCoords(posx,posy,posz, newx,newy,newz))
            end
        end
    end)
end
-- End props 
--[[]]--


Citizen.CreateThread(function()
    while true do
        Wait(100)
        local ped = NetworkIsInSpectatorMode()
        if ped == 1 then
            TriggerServerEvent("Anticheat:SpectateTrigger", "[MODDER CAUGHT]: Why are you stalking someone? Stoopid ass hoe");
        end
    end
end)
