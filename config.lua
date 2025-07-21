Config = {}

Config.Debug = false  -- NEED TO BE FALSE ON LIVE SERVERS
Config.defaultlang = "de_lang"

-- Script Settings

Config.ValidateOldUsers = true
-- MUST True to Validate Old Players Turn Off if message in Console Comes
-- Only if you Fresh Install this Script 
-- After the Database got Filled with your Old Users Turn this to False

Config.RightAwnsersNeeded = 2
-- Must be Same or Less then Questions if you got 2 Questions Max is 2

Config.BanOnFail = true -- Ban or Kick if Whitelist Failed?
Config.BanTime = 10 -- Time in Min

Config.Questions = {
    {
        Question = 'Was ist RDM ?',
        Awnser1 = 'Random Death Match',
        Awnser2 = 'Eine Vogelart',
        Awnser3 = 'Eine Währung in Rumänien',
        RightAwnser = 1,
    },
    {
        Question = 'Wie Viele Geiseln braucht man für einen Bank Raub ?',
        Awnser1 = '2 Geiseln',
        Awnser2 = '4 Geiseln',
        Awnser3 = '8 Geiseln',
        RightAwnser = 2,
    },
}