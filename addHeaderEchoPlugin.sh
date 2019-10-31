#!/bin/sh
PLUGINS="bundled"
mkdir tmp
cd tmp
# clone the plugin code that you would like to use
git clone https://github.com/jerneyio/kong-plugin-header-echo.git

#copy the code format into docker
docker cp kong-plugin-header-echo/kong/plugins/kong-plugin-header-echo/  kong-ent:/usr/local/share/lua/5.1/kong/plugins

#reload Kong with the appropriate plugin added. 
docker exec -ti kong-ent /bin/sh -c "KONG_PLUGINS='bundled,kong-plugin-header-echo' kong reload"

cd ..
rm -Rf tmp
