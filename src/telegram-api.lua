--[[

    Created by: João Guio
    Date:       06/04/2017

    https://github.com/jonnyguio/telegram-bot-api
    See MIT license regarding usage of code below.

]]--

local https = require 'ssl.https'
local JSON = require 'json'
local multipart = require 'multipart'

--[[
    functions to implement
        getMe [x]
        sendMessage [x]
        forwardMessage [x]
        sendPhoto
        sendAudio
        sendDocument
        sendSticker [x]
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
    if method == 'url_query' then
        for k, v in pairs(params) do
            f = f .. '&' .. k .. '=' .. v
        end
    end
    return f
end

local function request(bot, method, options)
    local parsedBody, body, code, headers, status, f   
    if bot.method == 'url_query' then
        f = format('', bot.method, options or {})
        body, code, headers, status = https.request(API.url .. bot.token .. '/' .. method .. '?' .. f)
        parsedBody = JSON.decode(body)
        assert(parsedBody.ok, 'Error: ' .. (parsedBody.description or ''))
    elseif bot.method == 'application/x-www-form' then
    elseif bot.method == 'application/json' then
    elseif bot.method == 'multipart/form-data' then 
    end
    return body, parsedBody, code, headers, status
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

--[[
function archetype
    local parsedBody, body, code, headers, status, f   
    if self.method == 'url_query' then
    elseif self.method == 'application/x-www-form' then
    elseif self.method == 'application/json' then
    elseif self.method == 'multipart/form-data' then 
    end

url_query archetype
    f = format('', self.method, options or {})
    body, code, headers, status = https.request(API.url .. self.token .. '/?')
    parsedBody = JSON.decode(body)
    assert(parsedBody.ok, 'Error: ' .. (parsedBody.description or ''))
]]--

-- Create a new Telegram BOT instance, using the BOT token.
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

-- Get basic informations from your bot
function API:getMe()
    return request(self, 'getMe')
end

-- Send message to a chat
function API:sendMessage(chat_id, text, options)
    --[[
        Optional parameters of sendMessage:
            parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup
    ]]--
    assert(chat_id and text, 'Error: no chat or text message specified in sendMessage')
    options = options or {}
    options['chat_id'] = chat_id
    options['text'] = text
    return request(self, 'sendMessage', options)
end

-- Forward message from a chat to another chat
function API:forwardMessage(chat_id, from_chat_id, message_id, options)
    --[[
        Optional parameters of forwardMessage
            disable_notification	
    ]]--
    assert(chat_id, 'Error: receiver chat not specified in forwardMessage')
    assert(from_chat_id, 'Error: sender chat not specified in forwardMessage')
    assert(message_id, 'Error: message not specified in forwardMessage')
    options = options or {}
    options['chat_id'] = chat_id
    options['from_chat_id'] = from_chat_id
    options['message_id'] = message_id
    return request(self, 'forwardMessage', options)
end

-- Sendo photo to a chat
function API:sendPhoto(chat_id, photo, options)
    assert(chat_id, 'Error: chat_id not specified in sendPhoto')
    assert(type(photo) == "string", 'Error: no string')

end 

function API:sendSticker(chat_id, sticker_id, options)
    assert(chat_id, 'Error: receiver chat not specified in sendSticker')
    assert(sticker_id, 'Error: file_id not specified in sendSticker')
    options = options or {}
    options['chat_id'] = chat_id
    options['sticker'] = sticker_id 	
    return request(self, 'sendSticker', options)
end

-- Download a file sent to the bot
function API:getFile(file_id)
    assert(file_id, 'Error: no file specified')
    return request(self, 'getFile', {['file_id'] = file_id})
end

function API:getUpdates(options)
    return request(self, 'getUpdates', options)
end

-- Add to BOT answer commands list a commandText and function
function API:addCommand(commandText, func)
    self.commands[commandText] = func
end

-- Just set the bot to receive updates
-- function API:setUpdates(bool)
--     if not self.webhookOn then
--         self.updatesOn = bool
--         setService(self, "update")
--     end
-- end

function API:downloadFile(file_id, filename)
    local body, parsedBody = request(self, 'getFile', {['file_id'] = file_id})
    file = assert(io.open(filename, 'wb'), 'Error opening file')
    local _body, _code, _headers, _status = https.request('https://api.telegram.org/file/bot' .. self.token .. '/' .. parsedBody.result.file_path)
    assert(_code == 200, 'Error: ' .. (_status or ''))
    file:write(_body)
    file:close()
end

-- Set the bot to an specific webhook
-- function API:setWebhook()
--     if not self.updatesOn then
--     end
-- end

return API