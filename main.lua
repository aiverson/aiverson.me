require "luvit/init" (function(...)

local process = require "process".globalProcess()
local weblit = require "./deps/weblit"

local app = weblit.app

local waitingSockets = {}

app.bind(
    {
        host = "0.0.0.0",
        port = tonumber(process.env.AIVERSON_PORT) or 8080
    }
).use(weblit.logger).use(weblit.autoHeaders).use(weblit.etagCache)

app.use(weblit.static "bundle:static/").use(weblit.static "static").start()

                     end)
