# telegram-bot-api
A Lua Telegram bot API.

## Install

Download `telegram-api.lua` and put inside project folder

On the first line of project:
`telegram_bot_api = require 'telegram-api.lua'`

You can also install using luarocks by executing the command `luarocks install lua-telegram-api

## Usage

See [Telegram Bot API documentation](https://core.telegram.org/bots/api)

## Features

### Telegram Commands

* getMe [x]
* sendMessage [x]
* forwardMessage [x]
* sendPhoto
* sendAudio
* sendDocument
* sendSticker [x]
* sendVideo
* sendLocation
* sendVenue
* sendContact
* sendChatAction
* getUserProfilePhotos
* getFile
* kickChatMember
* leaveChat
* unbanChatMember
* getChat
* getChatAdministrators
* getChatMembersCount
* getChatMember
* answerCallbackQuery
* editMessageText
* editMessageCaption
* editMessageReplyMarkup

### Additional Features
* add function to create commands to answer [x]
* getUpdates handler [x]
* setWebhook handler
