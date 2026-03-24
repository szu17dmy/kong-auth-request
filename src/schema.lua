local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-auth-request",
  fields = {
    { consumer = typedefs.no_consumer },
    {
      config = {
        type = "record",
        fields = {
          {
            timeout = {
              type = "number",
              default = 10000,
            },
          },
          {
            keepalive_timeout = {
              type = "number",
              default = 60000,
            }
          },
          {
            auth_uri = {
              type = "string",
              required = true,
            },
          },
          {
            origin_request_headers_to_forward_to_auth = {
              type = "array",
              elements = { type = "string" },
              default = {},
            },
          },
          {
            auth_response_headers_to_forward = {
              type = "array",
              elements = { type = "string" },
              default = {},
            },
          },
        },
      },
    },
  },
}
