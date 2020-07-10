BlacklistedEvents = Config.BlacklistedEvents;

local counter = {}
RegisterServerEvent("Anticheat:NoClip")
AddEventHandler("Anticheat:NoClip", function(distance)
    if not IsPlayerAceAllowed(source, "Anticheat.Bypass") then
        local name = GetPlayerName(source)
        local id = source;
        local ids = ExtractIdentifiers(id);
        local steam = ids.steam:gsub("steam:", "");
        local steamDec = tostring(tonumber(steam,16));
        if counter[ids.steam] ~= nil then 
            counter[ids.steam] = counter[ids.steam] + 1;
        else 
            counter[ids.steam] = 1;
        end
        if counter[ids.steam] ~= nil and counter[ids.steam] >= Config.NoClipTriggerCount then 
            steam = "https://steamcommunity.com/profiles/" .. steamDec;
            local gameLicense = ids.license;
            local discord = ids.discord;
            sendToDisc("CONFIRMED HACKER [Noclipping around]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
                'Steam: **' .. steam .. '**\n' ..
                'GameLicense: **' .. gameLicense .. '**\n' ..
                'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
                'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
            DropPlayer(id, "[MODDER CAUGHT]: Why you no-clipping and not staff? Stoopid ass hoe")
        end 
        Wait(6000);
        counter[ids.steam] = counter[ids.steam] - 1;
    end
end)

-- Props to Lance Good for this code (most of it at least): [https://github.com/DevLanceGood]
function IsLegal(entity) 
    local model = GetEntityModel(entity)
    if (model ~= nil) then
        if (GetEntityType(entity) == 1 and GetEntityPopulationType(entity) == 7) then 
            local towTruckDrivers = Config.TowTruckDrivers;
            local isTowTruckDriver = false;
            for i = 1, #towTruckDrivers do 
                if GetHashKey(towTruckDrivers[i]) == model then 
                    isTowTruckDriver = true;
                end 
            end 
            if not isTowTruckDriver then 
                return "Spawning Peds";
            else
                return false;
            end 
        end
        for i=1, #Config.BlacklistedModels do 
            local hashkey = tonumber(Config.BlacklistedModels[i]) ~= nil and tonumber(Config.BlacklistedModels[i]) or GetHashKey(Config.BlacklistedModels[i]) 
            if (hashkey == model) then
                if (GetEntityPopulationType(entity) ~= 7) then
                    return Config.BlacklistedModels[i];
                else
                    return false 
                end
            end
        end
    end
    return false
end
-- End props 

RegisterNetEvent("Anticheat:SpectateTrigger")
AddEventHandler("Anticheat:SpectateTrigger", function(reason)
    if not IsPlayerAceAllowed(source, "Anticheat.Bypass") then 
        local id = source;
        local ids = ExtractIdentifiers(id);
        local steam = ids.steam:gsub("steam:", "");
        local steamDec = tostring(tonumber(steam,16));
        steam = "https://steamcommunity.com/profiles/" .. steamDec;
        local gameLicense = ids.license;
        local discord = ids.discord;
        sendToDisc("CONFIRMED HACKER [Tried spectating a player]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
        DropPlayer(id, reason)
    end 
end)  
AddEventHandler('chatMessage', function(source, name, msg)
    local id = source;
    local ids = ExtractIdentifiers(id);
    local ip = ids.ip;
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/" .. steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;
    local realName = GetPlayerName(source);
    if (name ~= realName) then 
        sendToDisc("CONFIRMED HACKER [Fake Chat Message]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
        DropPlayer(id, "[MODDER CAUGHT]: Why you tryna be someone else? Stoopid ass hoe")
    end
end)

function GetEntityOwner(entity)
    if (not DoesEntityExist(entity)) then 
        return nil 
    end
    local owner = NetworkGetEntityOwner(entity)
    if (GetEntityPopulationType(entity) ~= 7) then return nil end
    return owner
end

AddEventHandler('explosionEvent', function(sender, ev)
    local sender = tonumber(sender)
    CancelEvent()
    if (sender ~= nil and sender > 0) then 
        CancelEvent()
    end
end)


for i=1, #BlacklistedEvents, 1 do
  RegisterServerEvent(BlacklistedEvents[i])
    AddEventHandler(BlacklistedEvents[i], function()
        local id = source;
        local ids = ExtractIdentifiers(id);
        local steam = ids.steam:gsub("steam:", "");
        local steamDec = tostring(tonumber(steam,16));
        steam = "https://steamcommunity.com/profiles/" .. steamDec;
        local gameLicense = ids.license;
        local discord = ids.discord;
        sendToDisc("CONFIRMED HACKER [Tried executing ".. BlacklistedEvents .."]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
      DropPlayer(id, "Lua execution: "..BlacklistedEvents[i],true)
    end)
end

AddEventHandler("entityCreating",  function(entity)
    local owner = GetEntityOwner(entity)
    local cancelled = false
    local model = IsLegal(entity);
    if (model) then 
        if (owner ~= nil and owner > 0) then
            local id = owner;
            local ids = ExtractIdentifiers(id);
            local steam = ids.steam:gsub("steam:", "");
            local steamDec = tostring(tonumber(steam,16));
            steam = "https://steamcommunity.com/profiles/" .. steamDec;
            local gameLicense = ids.license;
            local discord = ids.discord;
            sendToDisc("HACKER (Probably) [via Blacklisted Entity]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_ has spawned something...", 
                'Steam: **' .. steam .. '**\n' ..
                'GameLicense: **' .. gameLicense .. '**\n' ..
                'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
                'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n'
                .. 'Blacklisted Item: **' .. tostring(model) .. "**");
            KickPlayer(owner, "Possible Hacker (Blacklisted Item: " .. tostring(model) .. ")")
        end
        CancelEvent()
        cancelled = true
    end
end)
function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end
webhookURL = Config.Webhook;
function sendToDisc(title, message, footer)
    local embed = {}
    embed = {
        {
            ["color"] = 16711680, -- GREEN = 65280 --- RED = 16711680
            ["title"] = "**".. title .."**",
            ["description"] = "" .. message ..  "",
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }
    -- Start
    -- TODO Input Webhook
    PerformHttpRequest(webhookURL, 
    function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end
