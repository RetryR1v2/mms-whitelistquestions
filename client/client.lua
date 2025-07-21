local VORPcore = exports.vorp_core:GetCore()
local FeatherMenu =  exports['feather-menu'].initiate()

local CurrentQuestion = 1
local Frozen = false
local QuestionsStarted = false
local MaxQuestions = #Config.Questions

local RightAwnsers = 0
local WrongAwnsers = 0

local WhitelistPassed = false

--- OnPlayerSpawned

AddEventHandler("vorp_core:Client:OnPlayerSpawned",function()
    Citizen.Wait(5000)
    local ImWhitelisted = VORPcore.Callback.TriggerAwait('mms-whitelistquestions:callback:CheckIfWhitelisted')
    local ImBanned = VORPcore.Callback.TriggerAwait('mms-whitelistquestions:callback:CheckIfBanned')
    if not ImWhitelisted and not ImBanned then
        WhiteListMenu:Open({
            startupPage = WhiteListMenuPage1,
        })
        FreezeEntityPosition(PlayerPedId(),true)
        Frozen = true
    elseif not ImWhitelisted and ImBanned then
        TriggerServerEvent('mms-whitelistquestions:server:DropBannedPlayer')
    end
end)

--- DebugModeEnabled

Citizen.CreateThread(function ()
    if Config.Debug then
        Citizen.Wait(5000)
        local ImWhitelisted = VORPcore.Callback.TriggerAwait('mms-whitelistquestions:callback:CheckIfWhitelisted')
        if not ImWhitelisted then
            WhiteListMenu:Open({
                startupPage = WhiteListMenuPage1,
            })
            FreezeEntityPosition(PlayerPedId(),true)
            Frozen = true
        end
    end
end)

---------------------------------------------------------------------------------------------------------
--------------------------------------- WhiteList Menü------------------------------------------------
---------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function ()
    WhiteListMenu = FeatherMenu:RegisterMenu('WhiteList', {
        top = '10%',
        left = '30%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '800px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '550px',
                ['min-height'] = '250px'
            }
        },
        draggable = false,
        canclose = false
    }, {
        opened = function()
            --print("MENU OPENED!")
        end,
        closed = function()
            --print("MENU CLOSED!")
        end,
        topage = function(data)
            --print("PAGE CHANGED ", data.pageid)
        end
    })

    --- Seite 1 Startseite
    WhiteListMenuPage1 = WhiteListMenu:RegisterPage('seite1')
    WhiteListMenuPage1:RegisterElement('header', {
        value = _U('WhiteListHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenuPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    IntroText = WhiteListMenuPage1:RegisterElement('textdisplay', {
        slot = 'content',
        value = _U('IntroText'),
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
        }
    })
    WhiteListMenuPage1:RegisterElement('button', {
        label =  _U('StartWhitelistButton'),
        slot = 'content',
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        WhiteListMenu:Close({
        })
        TriggerEvent('mms-whitelistquestions:client:StartWhitelistProcess')
    end)
    LeaveServerText = WhiteListMenuPage1:RegisterElement('textdisplay', {
        slot = 'content',
        value = _U('AbortWhitelist'),
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
        }
    })
    WhiteListMenuPage1:RegisterElement('button', {
        label =  _U('LeaveServerButton'),
        slot = 'content',
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerServerEvent('mms-whitelistquestions:server:DropPlayer')
    end)
    WhiteListMenuPage1:RegisterElement('subheader', {
        value = _U('WhiteListSubHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenuPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
end)


RegisterNetEvent('mms-whitelistquestions:client:StartWhitelistProcess')
AddEventHandler('mms-whitelistquestions:client:StartWhitelistProcess',function()
    local MyAwnser = 0
    --- Seite 2 Fragebogen
    if not QuestionsStarted then
        QuestionsStarted = true
    else
        WhiteListMenuPage2:UnRegister()
    end
    WhiteListMenuPage2 = WhiteListMenu:RegisterPage('seite2')
    WhiteListMenuPage2:RegisterElement('header', {
        value = _U('QuestionHeader') .. CurrentQuestion,
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenuPage2:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    FragenText = WhiteListMenuPage2:RegisterElement('textdisplay', {
        slot = 'content',
        value = Config.Questions[CurrentQuestion].Question,
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
        }
    })
    WhiteListMenuPage2:RegisterElement('button', {
        label =  Config.Questions[CurrentQuestion].Awnser1,
        slot = 'content',
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        MyAwnser = 1
        if MyAwnser == Config.Questions[CurrentQuestion].RightAwnser then
            RightAwnsers = RightAwnsers + 1
        else
            WrongAwnsers = WrongAwnsers + 1
        end
        if CurrentQuestion == MaxQuestions then
            WhiteListMenu:Close({
            })
            TriggerEvent('mms-whitelistquestions:client:EndWhitelistProcess')
        else
            CurrentQuestion = CurrentQuestion + 1
            WhiteListMenu:Close({
            })
            TriggerEvent('mms-whitelistquestions:client:StartWhitelistProcess')
        end
    end)
    WhiteListMenuPage2:RegisterElement('button', {
        label =  Config.Questions[CurrentQuestion].Awnser2,
        slot = 'content',
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        MyAwnser = 2
        if MyAwnser == Config.Questions[CurrentQuestion].RightAwnser then
            RightAwnsers = RightAwnsers + 1
        else
            WrongAwnsers = WrongAwnsers + 1
        end
        if CurrentQuestion == MaxQuestions then
            WhiteListMenu:Close({
            })
            TriggerEvent('mms-whitelistquestions:client:EndWhitelistProcess')
        else
            CurrentQuestion = CurrentQuestion + 1
            WhiteListMenu:Close({
            })
            TriggerEvent('mms-whitelistquestions:client:StartWhitelistProcess')
        end
    end)
    WhiteListMenuPage2:RegisterElement('button', {
        label =  Config.Questions[CurrentQuestion].Awnser3,
        slot = 'content',
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        MyAwnser = 3
        if MyAwnser == Config.Questions[CurrentQuestion].RightAwnser then
            RightAwnsers = RightAwnsers + 1
        else
            WrongAwnsers = WrongAwnsers + 1
        end
        if CurrentQuestion == MaxQuestions then
            WhiteListMenu:Close({
            })
            TriggerEvent('mms-whitelistquestions:client:EndWhitelistProcess')
        else
            CurrentQuestion = CurrentQuestion + 1
            WhiteListMenu:Close({
            })
            TriggerEvent('mms-whitelistquestions:client:StartWhitelistProcess')
        end
    end)
    LeaveServerText = WhiteListMenuPage2:RegisterElement('textdisplay', {
        slot = 'content',
        value = _U('AbortWhitelist'),
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
        }
    })
    WhiteListMenuPage2:RegisterElement('button', {
        label =  _U('LeaveServerButton'),
        slot = 'content',
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerServerEvent('mms-whitelistquestions:server:DropPlayer')
    end)
    WhiteListMenuPage2:RegisterElement('subheader', {
        value = _U('WhiteListSubHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenuPage2:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenu:Open({
        startupPage = WhiteListMenuPage2,
    })
end)


RegisterNetEvent('mms-whitelistquestions:client:EndWhitelistProcess')
AddEventHandler('mms-whitelistquestions:client:EndWhitelistProcess',function()
    WhiteListMenuPage3 = WhiteListMenu:RegisterPage('seite3')
    WhiteListMenuPage3:RegisterElement('header', {
        value = _U('WhiteListEndedHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenuPage3:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    local TextLabel = ''
    if RightAwnsers >= Config.RightAwnsersNeeded then
        TextLabel = _U('WhitelistSuccessfull')
        WhitelistPassed = true
    else
        TextLabel = _U('WhitelistFailed')
    end
    FragenText = WhiteListMenuPage3:RegisterElement('textdisplay', {
        slot = 'content',
        value = TextLabel,
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
        }
    })
    WhiteListMenuPage3:RegisterElement('button', {
        label =  _U('FinishWhitelistButton'),
        slot = 'content',
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        if WhitelistPassed then
            if Frozen then
                FreezeEntityPosition(PlayerPedId(),false)
                Frozen = false
            end
            WhiteListMenu:Close({})
            TriggerServerEvent('mms-whitelistquestions:server:WhitelistSuccessfull')
        else
            TriggerServerEvent('mms-whitelistquestions:server:BanPlayer')
        end
    end)
    WhiteListMenuPage3:RegisterElement('subheader', {
        value = _U('WhiteListSubHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenuPage3:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    WhiteListMenu:Open({
        startupPage = WhiteListMenuPage3,
    })
end)
