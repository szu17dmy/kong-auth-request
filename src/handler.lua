local access = require "kong.plugins.kong-auth-request.access"

local AuthRequestHandler = {
  VERSION  = "1.0.0",
  PRIORITY = 900,
}

function AuthRequestHandler:access(conf)
  access.execute(conf)
end

return AuthRequestHandler
