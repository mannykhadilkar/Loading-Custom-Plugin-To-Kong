local typedefs = require "kong.db.schema.typedefs"


return {
  name = "jwt-routing",
  fields = {
    {
      route = typedefs.no_route,
    },
    {
      service = typedefs.no_service,
    },
    {
      consumer = typedefs.no_consumer,
    },
    {
      run_on = typedefs.run_on_first,
    },
    {
      protocols = typedefs.protocols_http,
    },
    {
      config = {
        type = "record",
        fields = {
        },
      },
    },
  },
}
