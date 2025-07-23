-- Server Side
local VORPcore = exports.vorp_core:GetCore()

-- ValidateOldUsers

Citizen.CreateThread(function()
    local AlreadyValidated = false
    if Config.ValidateOldUsers then
        local Users = MySQL.query.await("SELECT * FROM users", { })
        if #Users > 0 then -- If Greater then 0 he Already has a Char so not a new user
            local Whitelisted = MySQL.query.await("SELECT * FROM mms_whitelistquestions", { })
            if #Whitelisted == 0 then
                for h,v in ipairs(Users) do
                    MySQL.insert('INSERT INTO `mms_whitelistquestions` (identifier,whitelisted,banned,bantime) VALUES (?, ?, ?, ?)',
                    {v.identifier,1,0,0}, function()end)
                end
            else
                AlreadyValidated = true
            end
            if AlreadyValidated then
                Citizen.Wait(30000)
                print('^1⚠️ Users Already Validated TURN OFF Config.ValidateOldUsers ⚠️')
            else
                Citizen.Wait(30000)
                print('^1✅ Users Validated TURN OFF Config.ValidateOldUsers ✅')
            end
        end
    end
end)


-----------------------------------------------
------------- Register Callback ---------------
-----------------------------------------------

VORPcore.Callback.Register('mms-whitelistquestions:callback:CheckIfWhitelisted', function(source,cb)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local ImWhitelisted = false
    local WhitelistedUsers = MySQL.query.await("SELECT * FROM mms_whitelistquestions", { })
    if #WhitelistedUsers > 0 then
        for h,v in ipairs(WhitelistedUsers) do
            if v.identifier == identifier and v.whitelisted == 1 then
                ImWhitelisted = true
            end
        end
    end
    cb (ImWhitelisted)
end)

VORPcore.Callback.Register('mms-whitelistquestions:callback:CheckIfBanned', function(source,cb)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local ImBanned = false
    local WhitelistedUsers = MySQL.query.await("SELECT * FROM mms_whitelistquestions", { })
    if #WhitelistedUsers > 0 then
        for h,v in ipairs(WhitelistedUsers) do
            if v.identifier == identifier and v.banned == 1 then
                ImBanned = true
            end
        end
    end
    cb (ImBanned)
end)

-- DROP Player

RegisterServerEvent('mms-whitelistquestions:server:DropPlayer',function()
    local src = source
    DropPlayer(src,_U('WhitelistAborted'))
end)

-- Ban Player on Fail

RegisterServerEvent('mms-whitelistquestions:server:BanPlayer',function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local BanTime = Config.BanTime * 60000
    if Config.BanOnFail then
        local result = MySQL.query.await("SELECT * FROM mms_whitelistquestions WHERE identifier=@identifier", { ["@identifier"] = identifier})
        if #result > 0 then
            MySQL.update('UPDATE `mms_whitelistquestions` SET banned = ?  WHERE identifier = ?',{1, identifier})
            MySQL.update('UPDATE `mms_whitelistquestions` SET bantime = ?  WHERE identifier = ?',{BanTime, identifier})
        else
            MySQL.insert('INSERT INTO `mms_whitelistquestions` (identifier,whitelisted,banned,bantime) VALUES (?, ?, ?, ?)',
            {identifier,0,1,BanTime}, function()end)
        end
        DropPlayer(src,_U('YouAreBannedKickmessage'))
    else
        DropPlayer(src,_U('WhitelistFailedKickmessage'))
    end
end)

-- DROP Banned Player

RegisterServerEvent('mms-whitelistquestions:server:DropBannedPlayer',function()
    local src = source
    DropPlayer(src,_U('YouAreBannedKickmessage'))
end)

-- Whitelist Successfull

RegisterServerEvent('mms-whitelistquestions:server:WhitelistSuccessfull',function ()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local result = MySQL.query.await("SELECT * FROM mms_whitelistquestions WHERE identifier=@identifier", { ["@identifier"] = identifier})
    if #result > 0 then
        MySQL.update('UPDATE `mms_whitelistquestions` SET whitelisted = ?  WHERE identifier = ?',{1, identifier})
        MySQL.update('UPDATE `mms_whitelistquestions` SET banned = ?  WHERE identifier = ?',{0, identifier})
        MySQL.update('UPDATE `mms_whitelistquestions` SET bantime = ?  WHERE identifier = ?',{0, identifier})
    else
        MySQL.insert('INSERT INTO `mms_whitelistquestions` (identifier,whitelisted,banned,bantime) VALUES (?, ?, ?, ?)',
        {identifier,1,0,0}, function()end)
    end
end)

-- UnBan Cycles

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(30000)
        local WhitelistedUsers = MySQL.query.await("SELECT * FROM mms_whitelistquestions", { })
        if #WhitelistedUsers > 0 then
            for h,v in ipairs(WhitelistedUsers) do
                if v.bantime > 0 and v.banned == 1 then
                    local NewBantime = v.bantime - 30000
                    MySQL.update('UPDATE `mms_whitelistquestions` SET bantime = ?  WHERE identifier = ?',{NewBantime, v.identifier})
                elseif v.bantime <= 0 and v.banned == 1 then
                    MySQL.update('UPDATE `mms_whitelistquestions` SET bantime = ?  WHERE identifier = ?',{0, v.identifier})
                    MySQL.update('UPDATE `mms_whitelistquestions` SET banned = ?  WHERE identifier = ?',{0, v.identifier})
                end
            end
        end
    end
end)