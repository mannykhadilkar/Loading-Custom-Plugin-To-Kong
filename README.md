# Loading a custom plugin to Kong docker container
Documenting kong plugin development process when using docker. 

**Assumptions:**

1. _You have Docker installed_
1. _You have Bintray access_
1. _You have an environment variable KONG_LICENSE_DATA with a valid license.json loaded_
1. _You have a Github Person token https://github.com/settings/tokens_

### Overview
In this post, we will load a simple header echo plugin that has been documented here: https://www.jerney.io/header-echo-kong-plugin/. We will mostly follow the instructions posted in the previous link, however, we will add a script that loads it into our Kong docker environment. 

Here's an example of how it should work:

Request: $ curl -i http://localhost:8000/mock/request -H 'Host: mockbin.org' -H 'X-Request-Echo: Hello, world'
Response: contains the header 'X-Response-Echo: Hello, world'

Once the plugin is loaded into Kong, then we can exercise it and practice making additional changes to the plugin. 

### Getting environment setup

- Start Kong
  `> docker-compose up -d`
  
- Execute script to clone an existing kong plugin, copy it to Kong docker container location, and reload Kong. 
  `> ./addHeaderEchoPlugin.sh`
  
### Create a Service, Route, and Apply the Plugin.

- Create the service, "mock-service". 
  `> curl -X POST \
  --url "http://localhost:8001/services/" \
  --data "name=mock-service" \
  --data "url=http://mockbin.org" \`
  
- Create the route to the mock-service.
  `> curl -X POST \
    --url "http://localhost:8001/services/mock-service/routes" \
    --data "hosts[]=mockbin.org" \
    --data "paths[]=/mock" \`
    
- Validate setup by proxying a call to the route you created. 
  `>curl http://localhost:8000/mock/request -H 'Host: mockbin.org'`
  
- Now we're ready to add the plugin to our service. First execute this command and make sure the plugin shows up.
  `> curl http://localhost:8001/ | python -mjson.tool`
  
  Under "plugins": "available on server:" You will see the "kong-plugin-header-echo": true entry. 
  
- Now lets apply the plugin to the mock-service through the Admin API. NOTE: You can also do this using Kong Manager. 
  `> curl -X POST \
    --url "http://localhost:8001/services/mock-service/plugins" \
    --data "name=kong-plugin-header-echo" \
    | python -mjson.tool`
 
You should see an output like this:
`"created_at": 1537080281000,
    "config": {
        "requestHeader": "X-Request-Echo",
        "responseHeader": "X-Response-Echo"
    },
    "id": "e173ab1b-8094-4ab8-bcda-326bcbc46198",
    "enabled": true,
    "service_id": "4ecbe361-8dad-46fb-a6ab-13f3353c9805",
    "name": "kong-plugin-header-echo"`
    
 Notice the requestHeader and responseHeader. The requestHeader is what we will need to pass into the API call to get the responseHeader as output. 
 
 ### Now lets proxy a request to the plugin and see if it works!
 
 - Proxy a request using curl
  `> curl -i http://localhost:8000/mock/request -H 'Host: mockbin.org' -H 'X-Request-Echo: Hello, world'`
  
 - In the response, you will see a header: "X-Response-Echo: Hello, world"
 
 Thats it! Now you were able to quickly take a plugin and add it to your Kong docker environment. 
 
 ### More on the "addHeaderEchoPlugin.sh" file. 

In the file below, note that we are cloning the github repo, then we are copying the code into our Kong docker container, and then we are reloading Kong with the plugin enabled. This code can be modified to load any plugin you want into the Kong docker environment. 

```
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
```

## That concludes this brief tutorial on how to load a plugin into Kong

##### To cleanup: `> docker-compose down`

#### What you've learned/shown:

1. How to take a custom plugin and load it into the Kong docker container
2. How to add a service, route, and apply the custom plugin to the service. 


## Troubleshooting

If you run into problems loading this plugin into Kong, you can glean a lot of information from the docker container logs. After running the addHeaderEchoPlugin.sh script, you can see the docker logs by issuing the following command. 

  `> docker logs kong-ent`

If you want to tail the logs you can change the command to:

  `> docker logs kong-ent -f`
  
