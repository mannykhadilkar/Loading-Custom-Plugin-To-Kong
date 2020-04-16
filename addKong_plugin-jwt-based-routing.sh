#!/bin/sh
PLUGINS="bundled"



#copy the code format into docker
# i.e. docker cp kong/plugins/kong-plugin-header-echo/  kong-ent:/usr/local/share/lua/5.1/kong/plugins
docker cp kong/plugins/custom_kong_plugin-jwt-based-routing  kong-ent1:/usr/local/share/lua/5.1/kong/plugins

#reload Kong with the appropriate plugin added. 
docker exec -ti kong-ent1 /bin/sh -c "KONG_PLUGINS='bundled,custom_kong_plugin-jwt-based-routing' kong reload"
