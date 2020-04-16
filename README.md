# Loading a custom plugin to Kong docker container
1. Get the plugin code and put in the right format kong/plugins/<pluginname>
2. Get the docker container name for Kong
  
#copy the code format into docker by using the commands below and replacing the items in bold (example below)
`$ docker cp kong/plugins/**kong-plugin-header-echo**/  **kong-ent1**:/usr/local/share/lua/5.1/kong/plugins`

#reload Kong with the appropriate plugin added. 
` $docker exec -ti **kong-ent1** /bin/sh -c "KONG_PLUGINS='bundled,**kong-plugin-header-echo**' kong reload"`
