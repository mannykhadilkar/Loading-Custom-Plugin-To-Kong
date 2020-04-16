local jwt = require "kong.openid-connect.jwt"
local jws = require "kong.openid-connect.jws"


local kong = kong


local sub = string.sub
local type = type
local pairs = pairs
local lower = string.lower


local JwtRoutingHandler = {
  PRIORITY = 930,
  VERSION = "0.0.1"
}


function JwtRoutingHandler:rewrite(conf)
  local auth_header = kong.request.get_header("Authorization")
  if not auth_header then
    return
  end

  local auth_type = lower(sub(auth_header, 1, 6))
  if auth_type ~= "bearer" then
    return
  end

  local token = sub(auth_header, 8)
  local token_type = jwt.type(token)
  if token_type ~= "JWS" then
    return
  end

  token = jws.decode(token, { verify_signature = false })
  if type(token) ~= "table" then
    return
  end

  local claims = token.payload

  for claim, value in pairs(claims) do
    if type(claim) == "string" and type(value) == "string" then
      kong.service.request.set_header("JWT-Claim-" .. claim, value)
    end
  end

  kong.ctx.plugin.claims = claims
end


function JwtRoutingHandler:access(conf)
  local claims = kong.ctx.plugin.claims
  if not claims then
    return
  end

  for claim, value in pairs(claims) do
    if type(claim) == "string" and type(value) == "string" then
      kong.service.request.clear_header("JWT-Claim-" .. claim)
    end
  end

  kong.ctx.plugin.claims = nil
end


return JwtRoutingHandler
