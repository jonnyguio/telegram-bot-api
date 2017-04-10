--[[

    Created by: João Guio
    Date:       06/04/2017

    https://github.com/jonnyguio/telegram-bot-api
    See MIT license regarding usage of code below.

]]--

local https = require 'ssl.https'
local JSON = require 'json'

--[[
    functions to implement
        getMe [x]
        sendMessage [x]
        forwardMessage [x]
        sendPhoto
        sendAudio
        sendDocument
        sendSticker
        sendVideo
        sendLocation
        sendVenue
        sendContact
        sendChatAction
        getUserProfilePhotos
        getFile
        kickChatMember
        leaveChat
        unbanChatMember
        getChat
        getChatAdministrators
        getChatMembersCount
        getChatMember
        answerCallbackQuery
        editMessageText
        editMessageCaption
        editMessageReplyMarkup

    some functionalities
        add function to create commands to answer [x]
        getUpdates handler [x]
        setWebhook handler
        implement

]]--

local API = {}
API.__index = API
API.url = 'https://api.telegram.org/bot'

local function format(func, method, params)
    assert(type(func) == 'string', 'Use function name, not address') 
    assert(type(params) == 'table', 'Params should be a table')
    local f = ''
    if func == 'sendMessage' then
        if method == 'url_query' then
            for k, v in pairs(params) do
                f = f .. '&' .. k .. '=' .. v
            end
        end
    end
    return f
end

local function setService(bot, serviceType)
    if serviceType == 'update' then
        while 1 do
            body, code, headers, status = https.request(API.url .. bot.token .. '/getUpdates')
            parsedBody = JSON.decode(body)
            assert(parsedBody.ok, 'Error: ' .. (parsedBody.description or ''))
            
            for _, v in pairs(parsedBody.result) do
                if v.update_id > bot.lastUpdateMessage then
                    -- print(v.update_id, bot.lastUpdateMessage)
                    bot.lastUpdateMessage = v.update_id
                    for funcName, func in pairs(bot.commands) do
                        -- print(funcName, v.message.text)
                        if funcName == v.message.text then
                            func()
                        end
                    end
                end
            end
            os.execute("sleep " .. tonumber(1))
        end
    end
end

function API.new(token, method)
    local inst = {}
    setmetatable(inst, API)

    local body, code, headers, status = https.request(API.url .. token .. '/getMe')
    local parsedBody = JSON.decode(body)
    assert(parsedBody.ok, 'Error: Wrong Token')
    assert(method == nil or method == 'url_query' or method == 'application/json' or method == 'application/x-www-form' or method == 'multipart/form-data', 'Invalid method to format')

    inst.firstname = parsedBody.result.first_name
    inst.username = parsedBody.result.username
    inst.id = parsedBody.result.id
    inst.token = token
    inst.method = method or 'url_query'
    inst.commands = {}
    inst.updatesOn = false
    inst.webhookOn = false
    inst.lastUpdateMessage = 0
    print (inst.firstname, inst.username, inst.id, inst.token)

    return inst
end

function API:getMe()
    local body, code, headers, status = https.request(API.url .. self.token .. '/getMe')
    return JSON.decode(body)
end

function API:sendMessage(chat_id, text, options)
    --[[
        Optional parameters of sendMessage:
            parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup
    ]]--
    local parsedBody, body, code, headers, status, f
    if self.method == 'url_query' then
        f = format('sendMessage', self.method, options or {})
        body, code, headers, status = https.request(API.url .. self.token .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. text .. f)
        parsedBody = JSON.decode(body)
        assert(parsedBody.ok, 'Error: ' .. (parsedBody.description or ''))
    elseif self.method == 'application/x-www-form' then
    elseif self.method == 'application/json' then
    elseif self.method == 'multipart/form-data' then
    end
    return parsedBody
end

-- Forward message from a chat to another chat
function API:forwardMessage(chat_id, from_chat_id, message_id, options)
    --[[
        Optional parameters of forwardMessage
            disable_notification	
    ]]--
    local parsedBody, body, code, headers, status, f
    if self.method == 'url_query' then
        f = format('forwardMessage', self.method, options or {})
        body, code, headers, status = https.request(API.url .. self.token .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id .. f)
        parsedBody = JSON.decode(body)
        assert(parsedBody.ok, 'Error: ' .. (parsedBody.description or ''))
    elseif self.method == 'application/x-www-form' then
    elseif self.method == 'application/json' then
    elseif self.method == 'multipart/form-data' then
    end
end

-- Add to BOT answer commands list a commandText and function
function API:addCommand(commandText, func)
    self.commands[commandText] = func
end

-- Just set the bot to receive updates
function API:setUpdates(bool)
    if not self.webhookOn then
        self.updatesOn = bool
        setService(self, "update")
    end
end

-- Set the bot to an specific webhook
function API:setWebhook()
    if not self.updatesOn then
    end
end

return API