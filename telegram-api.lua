local https = require 'ssl.https'
local JSON = require 'json'

--[[
    functions to implement
    getMe
    sendMessage
    forwardMessage
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
]]

local API = {}
API.__index = API
API.url = 'https://api.telegram.org/bot'

function API.new(token, method)
    local inst = {}
    setmetatable(inst, API)

    local body, code, headers, status = https.request(API.url .. token .. '/getMe')
    local parsedBody = JSON.decode(body)
    if (not parsedBody.ok) then
        print("Wrong token.")
    else
        inst.firstname = parsedBody.result.first_name
        inst.username = parsedBody.result.username
        inst.id = parsedBody.result.id
        inst.token = token
        inst.method = method or "url_query"
        print (inst.firstname, inst.username, inst.id, inst.token)
    end

    return inst
end

function API:getMe()
    local body, code, headers, status = https.request(API.url .. self.token .. '/getMe')
    return JSON.decode(body)
end

function API:sendMessage(chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
    local body, code, headers, status 
    if self.method == "url_query" then
        body, code, headers, status = https.request(API.url .. self.token .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. text .. '&parse_mode=' .. parse_mode)
    end
    return JSON.decode(body)
end

return API