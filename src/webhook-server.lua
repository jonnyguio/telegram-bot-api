
--[[

    Created by: João Guio
    Date:       11/03/2018

    https://github.com/jonnyguio/telegram-bot-api
    See MIT license regarding usage of code below.

]]--

local https = require 'ssl.https'
local JSON = require 'json'
local multipart = require 'multipart'
local pegasus = require 'pegasus'

local WebhookServer = {}
WebhookServer.__index = WebhookServer

function WebhookServer.new(url, port, location)
    inst = {}
    setmetatable(inst, WebhookServer)
    
    inst.url = url or "localhost"
    inst.port = port or 8081
    inst.location = location or './www'
    inst.server = pegasus:new{
        port=tostring(inst.port),
        location=inst.location,
    }
    inst.server:start()
    return inst
end

function WebhookServer:start()
    if self.routes then
        self.server:start(function(request, response)
            for _, route in pairs(self.routes) do
                if route['path'] == request.path then
                    if route['method'] == request.method then
                        route['handler'](route['method'] == 'POST' and request.post)
                    end
                end
            end
        end) 
    else
        self.server:start(function(request, response)
            print('Server running on port '.. self.port)
        end)
    end
end 

function WebhookServer:addHandler(handler)
    --[[
        Default handler:
        {
            path : string, # path to route
            method : string, # method of this route
            handler : function (post_table : table) # handler function with argument as the request_post, if it's a post function,
        }
    ]]
    self.server:stop()
    table.insert(self.routes, handler)
    self.server:start()
end

return WebhookServer