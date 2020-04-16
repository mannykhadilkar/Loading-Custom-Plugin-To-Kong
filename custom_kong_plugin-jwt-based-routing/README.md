# kong_plugin-jwt-based-routing

This plugin takes claims from a jwt token passed in a request header and sets each claim in a custom request header ("Jwt-Claim-claimname": "value")

As is this plugin does not validate signatures, so it is recommended to use in conjunction w/ the JWT 
plugin or OIDC plugin to validate the signature of the token, and set routes by headers to direct the request to the correct
service. 

 

