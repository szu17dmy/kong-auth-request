# kong-auth-request

A Kong plugin that make GET auth request before proxying the original request.

📢 Compatible with Kong 3.9.

## Description

kong-auth-request is a reincarnation of [ngx http auth request](http://nginx.org/en/docs/http/ngx_http_auth_request_module.html "ngx http auth request").    

Plugin takes GET http request with Authorization header and send it to auth service (url is taken from plugin  configuration), then if auth response status code is 200 then plugin routes original request to upstream service with headers (header names are taken from plugin configuration) from auth response.   
If auth response code is greater than 299 then auth response is returned to client and origin request is not passed to upstream.

## Installation

### On Kubernetes, using the kong/ingress Helm chart

1. Create a ConfigMap with the plugin source code:

```bash
kubectl -n kong-namespace create configmap kong-auth-request \
    --from-file=access.lua=src/access.lua \
    --from-file=handler.lua=src/handler.lua \
    --from-file=schema.lua=src/schema.lua \
    -oyaml
```

2. Update `values.yaml` and perform a `helm upgrade`:

```yaml
controller:
  replicaCount: 1
  plugins:
    configMaps:
    - pluginName: kong-auth-request
      name: kong-auth-request

gateway:
  replicaCount: 1
  plugins:
    configMaps:
    - pluginName: kong-auth-request
      name: kong-auth-request
```

3. Create a `KongPlugin` resource:

```yaml
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: auth-request
  namespace: application-namespace
plugin: kong-auth-request
config:
  auth_uri: "http://auth-service/authorize"
  auth_response_headers_to_forward:
  - Authorization
  origin_request_headers_to_forward_to_auth:
  - Authorization
```

If you encounter errors such as `Error from server: error when creating "./auth-request.yaml": admission webhook "validations.kong.konghq.com" denied the request: plugin failed schema validation: schema violation (name: plugin 'kong-auth-request' not enabled; add it to the 'plugins' configuration property)`, ensure you have performed a rollout restart of Kong.

If issues persist, you may need to install plugins for all Kong deployments if you have multiple deployments. Visit [Not able to add custom plugin in kubernetes version 1.24.9 Works fine in 1.23 · Issue #789 · Kong/charts](https://github.com/Kong/charts/issues/789) for more information.

### Otherwise

Install plugin by luarocks package manager.  
```luarocks install kong-auth-request```

Add kong-auth-request to Kong by environment variable
```KONG_PLUGINS=bundled,kong-auth-request```   

or add it to kong.conf:  
```plugins = bundled,kong-auth-request```


## Configuration

```
curl -X POST \
--url "http://localhost:8001/services/fibery-api/plugins" \
--data "name=kong-auth-request" \
--data "config.auth_uri=http://auth.fibery.io/authorize" \
--data "config.auth_response_headers_to_forward[]=x-authorization"
--data "config.origin_request_headers_to_forward_to_auth[]=host"
```

config parameter | description
-----------------|--------------
config.auth_uri  | Plugin make a HTTP GET request with Authorization header to this URL before proxying the original request
config.auth_response_headers_to_forward | If auth request was successful then plugin takes header names from auth_response_headers_to_forward collection, then finds them in auth response headers and adds them into origin request before proxying it to upstream.
config.origin_request_headers_to_forward_to_auth | Origin request headers to pass to auth uri

## Compatibility

[handler.lua - Kong Gateway | Kong Docs](https://developer.konghq.com/custom-plugins/handler.lua/#migrating-from-the-baseplugin-module)

[schema.lua - Kong Gateway | Kong Docs](https://developer.konghq.com/custom-plugins/schema.lua/)

## Author

Andray Shotkin

## License

The MIT License (MIT)
=====================

Copyright (c) 2019 Andray Shotkin

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
