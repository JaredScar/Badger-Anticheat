BlacklistedEvents = Config.BlacklistedEvents;

webhookURL = ''

local counter = {}

function BanPlayer(src, reason) 
    local config = LoadResourceFile(GetCurrentResourceName(), "ac-bans.json")
    local cfg = json.decode(config)
    local ids = ExtractIdentifiers(src);
    local playerIP = ids.ip;
    local playerSteam = ids.steam;
    local playerLicense = ids.license;
    local playerXbl = ids.xbl;
    local playerLive = ids.live;
    local playerDisc = ids.discord;
    cfg[tostring(ip)] = reason;
    cfg[tostring(playerLicense)] = reason;
    if playerSteam ~= nil and playerSteam ~= "nil" and playerSteam ~= "" then 
        cfg[tostring(playerSteam)] = reason;
    end
    if playerXbl ~= nil and playerXbl ~= "nil" and playerXbl ~= "" then 
        cfg[tostring(playerXbl)] = reason;
    end
    if playerLive ~= nil and playerLive ~= "nil" and playerLive ~= "" then 
        cfg[tostring(playerLive)] = reason;
    end
    if playerDisc ~= nil and playerDisc ~= "nil" and playerDisc ~= "" then 
        cfg[tostring(playerDisc)] = reason;
    end
    SaveResourceFile(GetCurrentResourceName(), "ac-bans.json", json.encode(cfg, { indent = true }), -1)
end
function UnbanPlayer(ip)
    local config = LoadResourceFile(GetCurrentResourceName(), "ac-bans.json")
    local cfg = json.decode(config)
    cfg[tostring(ip)] = nil;
    SaveResourceFile(GetCurrentResourceName(), "ac-bans.json", json.encode(cfg, { indent = true }), -1)
end 
function GetBans()
    local config = LoadResourceFile(GetCurrentResourceName(), "ac-bans.json")
    local cfg = json.decode(config)
    return cfg;
end
local playTracker = {}
Citizen.CreateThread(function()
    while true do 
        Wait(0);
        for _, id in pairs(GetPlayers()) do 
            local ip = ExtractIdentifiers(id).ip;
            if playTracker[ip] ~= nil then 
                playTracker[ip] = playTracker[ip] + 1;
            else 
                playTracker[ip] = 1;
            end
        end
        Wait((1000 * 60)); -- Every minute 
    end
end)
function GetLatest(count)
    local latest = {};
    local lowest = 9999999;
    local lowestUser = nil;
    local ourCount = 0;
    local ourArr = {};
    for ip, playtime in pairs(playTracker) do 
        ourArr[ip] = playtime;
    end
    local retArr = {};
    while ourCount < count do 
        lowest = nil;
        local lowestIP = nil;
        lowestUser = nil;
        for ip, playtime in pairs(ourArr) do 
            for _, pid in pairs(GetPlayers()) do 
                local playerIP = ExtractIdentifiers(pid).ip;
                if tostring(ip) == tostring(playerIP) then 
                    if lowest == nil or lowest >= playtime then 
                        lowestIP = ip;
                        lowest = playtime 
                        lowestUser = pid;
                    end
                end 
            end 
        end
        if lowest ~= nil then 
            ourArr[lowestIP] = nil;
            table.insert(retArr, {lowestUser, lowest});
        end 
        ourCount = ourCount + 1;
    end
    return retArr;
end
RegisterCommand("entitywipe", function(source, args, raw)
    local playerID = args[1]
    if (IsPlayerAceAllowed(source, "AntiCheat.Moderation")) then
        if (playerID ~= nil and tonumber(playerID) ~= nil) then 
            EntityWipe(source, tonumber(playerID))
        end
    end
end, false)
function EntityWipe(source, target)
    TriggerClientEvent("anticheat:EntityWipe", -1, tonumber(target))
end
RegisterCommand("latest", function(source, args, rawCommand) 
    local latestUsers = GetLatest(6);
    for i = 1, #latestUsers do 
        local user = latestUsers[i][1];
        local playTime = latestUsers[i][2];
        TriggerClientEvent('chatMessage', source, "^5[^1Badger-Anticheat^5] ^3Player ^3[^4".. tostring(user) .. "^3] ^4" .. 
            GetPlayerName(user) .. " ^3has played ^4" .. playTime ..
            " ^3minutes so far...");
    end
end)
Citizen.CreateThread(function()
    while true do 
        Wait(10000); -- Every 10 seconds 
        local bans = GetBans();
        for _, id in pairs(GetPlayers()) do 
            local playerIP = ExtractIdentifiers(id).ip;
            if bans[tostring(playerIP)] ~= nil then 
                -- Banned, kick em 
                DropPlayer(id, "[Badger-Anticheat] " .. bans[tostring(playerIP)]);
            end
        end
    end
end)
function OnPlayerConnecting(name, setKickReason, deferrals)
    deferrals.defer();
    print("[Badger-Anticheat] Checking their Ban Data");
    local src = source;
    local ids = ExtractIdentifiers(src);
    local playerIP = ids.ip;
    local playerSteam = ids.steam;
    local playerLicense = ids.license;
    local playerXbl = ids.xbl;
    local playerLive = ids.live;
    local playerDisc = ids.discord;
    local bans = GetBans();
    local banned = false;
    if (bans[tostring(playerIP)] ~= nil) or (bans[tostring(playerSteam)] ~= nil) or 
    (bans[tostring(playerLicense)] ~= nil) or (bans[tostring(playerXbl)] ~= nil) or 
    (bans[tostring(playerXbl)] ~= nil) or (bans[tostring(playerLive)] ~= nil) or (bans[tostring(playerDisc)] ~= nil) then 
        -- They are banned 
        local reason = "Unknown";
        for id, v in pairs(ids) do 
            if bans[tostring(id)] ~= nil then 
                reason = bans[tostring(id)];
            end
        end
        print("[Badger-Anticheat] (BANNED PLAYER) Player " .. GetPlayerName(src) .. " tried to join, but was banned for: " .. reason);
        deferrals.done("[Badger-Anticheat] " .. reason);
        banned = true;
        CancelEvent();
        return;
    end
    if not banned then 
        deferrals.done();
    end
end
RegisterCommand("acban", function(source, args, raw)
    -- /acban <id> <reason> 
    local src = source;
    if IsPlayerAceAllowed(src, "Badger-Anticheat.ACban") then 
        -- They can ban players this way
        if #args < 2 then 
            -- Not valid enough num of arguments 
            TriggerClientEvent('chatMessage', source, "^5[^1Badger-Anticheat^5] ^1ERROR: You have supplied invalid amount of arguments... " ..
                "^2Proper Usage: /acban <id> <reason>");
            return;
        end
        local id = args[1]
        if ExtractIdentifiers(args[1]) ~= nil then 
            -- Valid player supplied 
            local ids = ExtractIdentifiers(id);
            local steam = ids.steam;
            local gameLicense = ids.license;
            local discord = ids.discord;
            local reason = table.concat(args, ' '):gsub(args[1] .. " ", "");
            BanPlayer(args[1], reason);
            sendToDisc("[BANNED] Banned by " .. GetPlayerName(src) .. ": _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
                'Reason: **' .. reason .. '**\n' ..
                'Steam: **' .. steam .. '**\n' ..
                'GameLicense: **' .. gameLicense .. '**\n' ..
                'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
                'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
            DropPlayer(id, "[Badger-Anticheat]: Banned by player " .. GetPlayerName(src) .. " for reason: " .. reason);
        else 
            -- Not a valid player supplied 
            TriggerClientEvent('chatMessage', source, "^5[^1Badger-Anticheat^5] ^1ERROR: There is no valid player with that ID online... " ..
                "^2Proper Usage: /acban <id> <reason>");
        end
    end
end)
AddEventHandler("playerConnecting", OnPlayerConnecting)

AddEventHandler("clearPedTasksEvent", function(sender, data)
    print(sender, GetPlayerName(sender), json.encode(data))
    print("GetPlayerPed: " .. GetPlayerPed(sender));
    -- 128, SloPro, { "pedId": 1, "unk1": true }
end)

RegisterServerEvent("Anticheat:NoClip")
AddEventHandler("Anticheat:NoClip", function(distance)
    if Config.Components.AntiNoclip and not IsPlayerAceAllowed(source, "Anticheat.Bypass") then
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
            if (Config.BanComponents.AntiNoClip) then 
                BanPlayer(id, "Why you no-clipping and not staff? Stoopid ass hoe")
                sendToDisc("[BANNED] CONFIRMED HACKER (NoClipping around): _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
                'Steam: **' .. steam .. '**\n' ..
                'GameLicense: **' .. gameLicense .. '**\n' ..
                'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
                'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
            else 
                sendToDisc("CONFIRMED HACKER [NoClipping around]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
                'Steam: **' .. steam .. '**\n' ..
                'GameLicense: **' .. gameLicense .. '**\n' ..
                'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
                'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
            end
            DropPlayer(id, "[Badger-Anticheat]: Why you no-clipping and not staff? Stoopid ass hoe")
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
            local WhitelistPedModels = Config.WhitelistPedModels;
            local isWhitelisted = false;
            for i = 1, #WhitelistPedModels do 
                if GetHashKey(WhitelistPedModels[i]) == model then 
                    isWhitelisted = true;
                end 
            end 
            if not isWhitelisted then 
                --return "Spawning Peds";
				return false;
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
RegisterNetEvent("Anticheat:ModderESX")
AddEventHandler("Anticheat:ModderESX", function(type, reason)
    local id = source;
    local ids = ExtractIdentifiers(id);
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/" .. steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;
    if Config.BanComponents.AntiESX then 
        BanPlayer(id, reason);
        sendToDisc("[BANNED] " .. type .. ": _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
        'Steam: **' .. steam .. '**\n' ..
        'GameLicense: **' .. gameLicense .. '**\n' ..
        'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
        'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
    else 
        sendToDisc("" .. type .. ": _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
        'Steam: **' .. steam .. '**\n' ..
        'GameLicense: **' .. gameLicense .. '**\n' ..
        'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
        'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
    end
    DropPlayer(id, reason)
end)  
RegisterNetEvent("Anticheat:Modder")
AddEventHandler("Anticheat:Modder", function(type, reason)
    local id = source;
    local ids = ExtractIdentifiers(id);
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/" .. steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;
    if Config.BanComponents.AntiCommands then 
        BanPlayer(id, reason);
        sendToDisc("[BANNED] " .. type .. ": _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
        'Steam: **' .. steam .. '**\n' ..
        'GameLicense: **' .. gameLicense .. '**\n' ..
        'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
        'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
    else 
        sendToDisc("" .. type .. ": _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
        'Steam: **' .. steam .. '**\n' ..
        'GameLicense: **' .. gameLicense .. '**\n' ..
        'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
        'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
    end
    DropPlayer(id, reason)
end) 
RegisterNetEvent("Anticheat:ModderNoKick")
AddEventHandler("Anticheat:ModderNoKick", function(type, reason, bool)
    local id = source;
    local ids = ExtractIdentifiers(id);
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/" .. steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;
    sendToDisc("" .. type .. ": _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
        'Steam: **' .. steam .. '**\n' ..
        'GameLicense: **' .. gameLicense .. '**\n' ..
        'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
        'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
    if bool then 
        DropPlayer(id, reason)
    end
end)  
RegisterNetEvent("Anticheat:SpectateTrigger")
AddEventHandler("Anticheat:SpectateTrigger", function(reason)
    if Config.Components.AntiSpectate and not IsPlayerAceAllowed(source, "Anticheat.Bypass") then 
        local id = source;
        local ids = ExtractIdentifiers(id);
        local steam = ids.steam:gsub("steam:", "");
        local steamDec = tostring(tonumber(steam,16));
        steam = "https://steamcommunity.com/profiles/" .. steamDec;
        local gameLicense = ids.license;
        local discord = ids.discord;
        if Config.BanComponents.AntiSpectate then 
            BanPlayer(id, reason);
            sendToDisc("[BANNED] CONFIRMED HACKER (Tried spectating a player): _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
        else 
            sendToDisc("CONFIRMED HACKER [Tried spectating a player]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
        end
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
        if Config.BanComponents.AntiFakeMessage then 
            BanPlayer(id, "Why you tryna be someone else? Stoopid ass hoe")
            sendToDisc("[BANNED] CONFIRMED HACKER (Fake Chat Message): _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n'
            .. 'Tried to say: `' .. msg .. '` with name `' .. name .. '`');
        else 
            sendToDisc("CONFIRMED HACKER [Fake Chat Message]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n'
            .. 'Tried to say: `' .. msg .. '` with name `' .. name .. '`');
        end
        DropPlayer(id, "[Badger-Anticheat]: Why you tryna be someone else? Stoopid ass hoe")
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
        if Config.BanComponents.AntiBlacklistedEvent then 
            BanPlayer(id, "Lua execution: "..BlacklistedEvents[i]);
            sendToDisc("[BANNED] CONFIRMED HACKER (Tried executing `".. BlacklistedEvents[i] .."`): _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
        else 
            sendToDisc("CONFIRMED HACKER [Tried executing `".. BlacklistedEvents[i] .."`]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_", 
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n');
        end
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
            DropPlayer(owner, "Possible Hacker (Blacklisted Item: " .. tostring(model) .. ")")
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
