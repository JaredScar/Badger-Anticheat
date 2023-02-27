-- Server Config:
webhookURL = ''


-- CODE [DO NOT TOUCH]:
BlacklistedEvents = Config.BlacklistedEvents;

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
    local banData = {};
    banData['ID'] = tonumber(getNewBanID());
    banData['ip'] = "NONE SUPPLIED";
    banData['reason'] = reason;
    banData['license'] = "NONE SUPPLIED";
    banData['steam'] = "NONE SUPPLIED";
    banData['xbl'] = "NONE SUPPLIED";
    banData['live'] = "NONE SUPPLIED";
    banData['discord'] = "NONE SUPPLIED";
    if ip ~= nil and ip ~= "nil" and ip ~= "" then 
        banData['ip'] = tostring(ip);
    end
    if playerLicense ~= nil and playerLicense ~= "nil" and playerLicense ~= "" then 
        banData['license'] = tostring(playerLicense);
    end
    if playerSteam ~= nil and playerSteam ~= "nil" and playerSteam ~= "" then 
        banData['steam'] = tostring(playerSteam);
    end
    if playerXbl ~= nil and playerXbl ~= "nil" and playerXbl ~= "" then 
        banData['xbl'] = tostring(playerXbl);
    end
    if playerLive ~= nil and playerLive ~= "nil" and playerLive ~= "" then 
        banData['live'] = tostring(playerXbl);
    end
    if playerDisc ~= nil and playerDisc ~= "nil" and playerDisc ~= "" then 
        banData['discord'] = tostring(playerDisc);
    end
    cfg[tostring(GetPlayerName(src))] = banData;
    SaveResourceFile(GetCurrentResourceName(), "ac-bans.json", json.encode(cfg, { indent = true }), -1)
end
function getNewBanID()
    local config = LoadResourceFile(GetCurrentResourceName(), "ac-bans.json")
    local cfg = json.decode(config)
    local banID = 0;
    for k, v in pairs(cfg) do 
        banID = banID + 1;
    end
    return (banID + 1);
end

RegisterNetEvent('Anticheat:CheckStaff')
AddEventHandler('Anticheat:CheckStaff', function()
    local src = source;
    if IsPlayerAceAllowed(src, 'Anticheat.Bypass') then 
        TriggerClientEvent('Anticheat:CheckStaffReturn', src, true);
    else 
        TriggerClientEvent('Anticheat:CheckStaffReturn', src, false);
    end
end)

RegisterNetEvent('Anticheat:ScreenshotSubmit')
AddEventHandler('Anticheat:ScreenshotSubmit', function()
    local src = source;
    if not IsPlayerAceAllowed(src, "Anticheat.Bypass") then 
        local screenshotOptions = {
            encoding = 'png',
            quality = 1
        }    
        local ids = ExtractIdentifiers(src);
        local playerIP = ids.ip;
        local playerSteam = ids.steam;
        local playerLicense = ids.license;
        local playerXbl = ids.xbl;
        local playerLive = ids.live;
        local playerDisc = ids.discord;
        exports['discord-screenshot']:requestCustomClientScreenshotUploadToDiscord(src, webhookURL, screenshotOptions, {
            username = '[BADGER-ANTICHEAT] https://github.com/JaredScar/Badger-Anticheat',
            avatar_url = 'https://forum.cfx.re/user_avatar/forum.cfx.re/officialbadger/120/258293_2.png',
            content = '',
            embeds = {
                {
                    color = 16711680,
                    author = {
                        name = '[BADGER-ANTICHEAT]',
                        icon_url = 'https://forum.cfx.re/user_avatar/forum.cfx.re/officialbadger/120/258293_2.png'
                    },
                    title = '[Possible Modder] Player has triggered blacklisted keys...',
                    description = '**__Player Identifiers:__** \n\n'
                    .. '**Server ID:** `' .. src .. '`\n\n'
                    .. '**Username:** `' .. GetPlayerName(src) .. '`\n\n'
                    .. '**IP:** `' .. playerIP .. '`\n\n'
                    .. '**Steam:** `' .. playerSteam .. '`\n\n'
                    .. '**License:** `' .. playerLicense .. '`\n\n'
                    .. '**Xbl:** `' .. playerXbl .. '`\n\n'
                    .. '**Live:** `' .. playerLive .. '`\n\n'
                    .. '**Discord:** `' .. playerDisc .. '`\n\n',
                    footer = {
                        text = "[" .. src .. "]" .. GetPlayerName(src),
                    }
                }
            }
        });
    end
end)


RegisterCommand('ac-unban', function(source, args, rawCommand)
    local src = source;
    if (src <= 0) then
        -- Console unban
        if #args == 0 then 
            -- Not enough arguments
            print('^3[^6Badger-Anticheat^3] ^1Not enough arguments...');
            return; 
        end
        local banID = args[1];
        if tonumber(banID) ~= nil then
            local playerName = UnbanPlayer(banID);
            if playerName then
                print('^3[^6Badger-Anticheat^3] ^0Player ^1' .. playerName 
                .. ' ^0has been unbanned from the server by ^2CONSOLE');
                TriggerClientEvent('chatMessage', -1, '^3[^6Badger-Anticheat^3] ^0Player ^1' .. playerName 
                .. ' ^0has been unbanned from the server by ^2CONSOLE'); 
            else 
                -- Not a valid ban ID
                print('^3[^6Badger-Anticheat^3] ^1That is not a valid ban ID. No one has been unbanned!'); 
            end
        end
        return;
    end 
    if IsPlayerAceAllowed(src, "Badger-Anticheat.ACban") then 
        if #args == 0 then 
            -- Not enough arguments
            TriggerClientEvent('chatMessage', src, '^3[^6Badger-Anticheat^3] ^1Not enough arguments...');
            return; 
        end
        local banID = args[1];
        if tonumber(banID) ~= nil then 
            -- Is a valid ban ID 
            local playerName = UnbanPlayer(banID);
            if playerName then
                TriggerClientEvent('chatMessage', -1, '^3[^6Badger-Anticheat^3] ^0Player ^1' .. playerName 
                .. ' ^0has been unbanned from the server by ^2' .. GetPlayerName(src)); 
            else 
                -- Not a valid ban ID
                TriggerClientEvent('chatMessage', src, '^3[^6Badger-Anticheat^3] ^1That is not a valid ban ID. No one has been unbanned!'); 
            end
        else 
            -- Not a valid number
            TriggerClientEvent('chatMessage', src, '^3[^6Badger-Anticheat^3] ^1That is not a valid number...'); 
        end
    end
end)
function UnbanPlayer(banID)
    local config = LoadResourceFile(GetCurrentResourceName(), "ac-bans.json")
    local cfg = json.decode(config)
    for k, v in pairs(cfg) do 
        local id = tonumber(v['ID']);
        if id == tonumber(banID) then 
            local name = k;
            cfg[k] = nil;
            SaveResourceFile(GetCurrentResourceName(), "ac-bans.json", json.encode(cfg, { indent = true }), -1)
            return name;
        end
    end
    return false;
end 
--[[
@param src - The player server ID supplied

function isBanned(src)
    FOUND: returns { banID: tonumber(banID), reason: tostring(reason) }
    NOT FOUND: returns false
]]--
function isBanned(src)
    local config = LoadResourceFile(GetCurrentResourceName(), "ac-bans.json")
    local cfg = json.decode(config)
    local ids = ExtractIdentifiers(src);
    local playerIP = ids.ip;
    local playerSteam = ids.steam;
    local playerLicense = ids.license;
    local playerXbl = ids.xbl;
    local playerLive = ids.live;
    local playerDisc = ids.discord;
    for k, v in pairs(cfg) do 
        local reason = v['reason']
        local id = v['ID']
        local ip = v['ip']
        local license = v['license']
        local steam = v['steam']
        local xbl = v['xbl']
        local live = v['live']
        local discord = v['discord']
        if tostring(ip) == tostring(playerIP) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(license) == tostring(playerLicense) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(steam) == tostring(playerSteam) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(xbl) == tostring(playerXbl) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(live) == tostring(playerLive) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(discord) == tostring(playerDisc) then return { ['banID'] = id, ['reason'] = reason } end;
    end
    return false;
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
--[[
Citizen.CreateThread(function()
    while true do 
        Wait(40000); -- Every 40 seconds 
        for _, id in pairs(GetPlayers()) do 
            if isBanned(id) then 
                -- Banned, kick em 
                DropPlayer(id, "[Badger-Anticheat] " .. bans[tostring(playerIP)]);
            end
        end
    end
end)
]]--
function OnPlayerConnecting(name, setKickReason, deferrals)
    deferrals.defer();
    local src = source;
    print("[Badger-Anticheat] Checking ban data for "..GetPlayerName(src));
    local banned = false;
    local ban = isBanned(src);
    Citizen.Wait(100);
    if ban then 
        -- They are banned 
        local reason = ban['reason'];
        local printMessage = nil;
        if string.find(reason, "[Badger-Anticheat]") then 
            printMessage = "" 
        else 
            printMessage = "[Badger-Anticheat] " 
        end 
        print("[BANNED PLAYER] Player " .. GetPlayerName(src) .. " tried to join, but was banned for: " .. reason);
        deferrals.done(printMessage .. "(BAN ID: " .. ban['banID'] .. ") " .. reason);
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
                BanPlayer(id, Config.Messages.NoClipTriggered)
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
            DropPlayer(id, "[Badger-Anticheat]: " .. Config.Messages.NoClipTriggered)
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
            BanPlayer(id, "[Badger-Anticheat]: " .. Config.Messages.ChatMessageTriggered)
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
        DropPlayer(id, "[Badger-Anticheat]: " .. Config.Messages.ChatMessageTriggered)
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
        local reason = Config.Messages.BlacklistedEventTriggered:gsub("{EVENT}", BlacklistedEvents[i]);
        if Config.BanComponents.AntiBlacklistedEvent then 
            BanPlayer(id, "[Badger-Anticheat]: " .. reason);
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
      DropPlayer(id, "[Badger-Anticheat]: " .. reason)
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
            local reason = Config.Messages.BlacklistedEntity:gsub("{ENTITY}", tostring(model));
            sendToDisc("HACKER (Probably) [via Blacklisted Entity]: _[" .. tostring(id) .. "] " .. GetPlayerName(id) .. "_ has spawned something...", 
                'Steam: **' .. steam .. '**\n' ..
                'GameLicense: **' .. gameLicense .. '**\n' ..
                'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
                'Discord UID: **' .. discord:gsub('discord:', '') .. '**\n'
                .. 'Blacklisted Item: **' .. tostring(model) .. "**");
            DropPlayer(owner, "[Badger-Anticheat]: " .. reason);
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
    PerformHttpRequest(webhookURL, 
    function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end



--Optional Features depending on the server disable if not suitable for yours!
AddEventHandler("clearPedTasksEvent", function(sender, data)
    if Config.Components.AntiCancelAnimations then 
    CancelEvent()
    end 
    -- Stops other players kicking people out of cars
end)

AddEventHandler('removeWeaponEvent', function(sender, data)
    if Config.Components.AntiRemoveOtherPlayersWeapons then 
        CancelEvent()
    end 
    -- Would only affect if you have scripts removing other people's weapons. (stops players removing other players weapons)
end)

AddEventHandler('giveWeaponEvent', function(sender, data)
    if Config.Components.StopOtherPlayersGivingEachOtherWeapons then 
    CancelEvent()
    end 
    -- Stops other players giving people weapons (doesn't affect single people unless you have give weapons on menus and etc.)
end)



CreateThread(function()
    if Config.Components.ModMenuChecks then
        Wait(1000)
        local added = false
        for i = 1, GetNumResources() do
            local resource_id = i - 1
            local resource_name = GetResourceByFindIndex(resource_id)
            if resource_name ~= GetCurrentResourceName() then
                for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
                    local data = LoadResourceFile(resource_name, v)
                    if data and type(data) == 'string' and string.find(data, 'acloader.lua') == nil then
                        data = data .. '\nclient_script "@' .. GetCurrentResourceName() .. '/acloader.lua"'
                        SaveResourceFile(resource_name, v, data, -1)
                        print('Added to resource: ' .. resource_name)
                        added = true
                    end
                end
            end
        end
        if added then
            print('Modified 1 or more resources. It is required to restart your server so these changes can now take place.')
        end
    else 
        Wait(1000)
        local added = false
        for i = 1, GetNumResources() do
            local resource_id = i - 1
            local resource_name = GetResourceByFindIndex(resource_id)
            if resource_name ~= GetCurrentResourceName() then
                for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
                    local data = LoadResourceFile(resource_name, v)
                    if data and type(data) == 'string' and string.find(data, 'acloader.lua') ~= nil then
                       -- data = data:lower()
                        local removed = string.gsub(data, 'client_script "%@badger%-anticheat%-master%/acloader.lua"', "")
                        SaveResourceFile(resource_name, v, removed, -1)
                        print('Removed from resource: ' .. resource_name)
                        added = true
                    end
                end
            end
        end
        if added then
            print('[Badger-AC] Uninstall Mod-Menu-Checks | Modified 1 or more resources. It is required to restart your server so these changes can now take place.')
        end
    end
end)


local validResourceList
local function collectValidResourceList()
    validResourceList = {}
    for i = 0, GetNumResources() - 1 do
        validResourceList[GetResourceByFindIndex(i)] = true
    end
end
collectValidResourceList()
if Config.Components.StopUnauthorizedResources then
    AddEventHandler("onResourceListRefresh", collectValidResourceList)
    RegisterNetEvent("ANTICHEAT:CHECKRESOURCES")
    AddEventHandler("ANTICHEAT:CHECKRESOURCES", function(givenList)
        local source = source
        Wait(50)
        for _, resource in ipairs(givenList) do
            if not validResourceList[resource] then
                BanPlayer(source, "[Badger-Anticheat]: " .. Config.Messages.UnauthorizedResources:gsub("{RESOURCE}", resource));
            end
        end
    end)
end
