# http-http

In this example, the app pod will connect to an external service using HTTP, and the egress gateway will connect using HTTP also.

The _OCP_APPS_DOMAIN_ is the external domain in which the nginx server will be exposed.

## Deploy the Nginx server

Set the external domain in the _[params.env](./params.env)_ and _[route-nginx.yaml](./nginx-deploy/route-nginx.yaml)_  files.

Deploying a Nginx Server with OpenShift routes.

Create the new project:
```
oc new-project nginx
```

Create the SA for the nginx server:
```
oc create sa nginx
oc adm policy add-scc-to-user anyuid -z nginx
```

Create the Nginx conf:
```
oc create cm nginx-configmap -n nginx --from-file=nginx.conf=./nginx-deploy/nginx.conf
```

Deploy the Nginx server:
```
oc process -f nginx-deploy/nginx.yaml --param-file=params.env --ignore-unknown-parameters | oc apply -n nginx -f -
```

Finally, expose the nginx server creating an OpenShift route:
```
oc apply -f nginx-deploy/route-nginx.yaml -n nginx
```

Test the Nginx server:
```
export NGINX_URL=$(oc get route nginx-http -n nginx -o jsonpath='{.spec.host}')
curl -vI http://$NGINX_URL
```

## Case 1: Using ISTIO_MUTUAL between the pod and the egress GW. Deploy the client inside the mesh to connect to the Nginx server.

We are going to deploy a _sleep_ pod. The project used is _bookinfo_ and this NS must be member of the Service Mesh.

Deploy the sleep application in the bookinfo namespace:
```
oc apply -f sleep/deploy.yaml -n bookinfo
```

Run a curl command to test the connectivity. Since the Istio objects are not created, you'll receive a 502 error:
```
export NGINX_URL=$(oc get route nginx-http -n nginx -o jsonpath='{.spec.host}')
oc exec -n bookinfo -c sleep $(oc get pods -n bookinfo -o NAME | grep sleep | tail -n1) -- watch -n1 curl -vIs $NGINX_URL
```

Update the files under _ossm_ISTIO_MUTUAL/_ folder with the OCP domain and reate the Istio objects to route the traffic through the Egress Gateway:
```
oc apply -n istio-system -f ossm_ISTIO_MUTUAL/istio-system/se-nginx.yaml
oc apply -n istio-system -f ossm_ISTIO_MUTUAL/istio-system/gw-nginx.yaml
oc apply -n istio-system -f ossm_ISTIO_MUTUAL/istio-system/vs-egress-nginx.yaml
oc apply -n istio-system -f ossm_ISTIO_MUTUAL/istio-system/dr-egress-nginx.yaml
oc apply -n bookinfo -f ossm_ISTIO_MUTUAL/bookinfo/dr-sleep-egress.yaml
oc apply -n bookinfo -f ossm_ISTIO_MUTUAL/bookinfo/vs-sleep-egress.yaml
```

The curl command begins to work properly and returns a 200 status code.

Delete the Istio objects:
```
oc delete -n istio-system -f ossm_ISTIO_MUTUAL/istio-system/
oc delete -n bookinfo -f ossm_ISTIO_MUTUAL/bookinfo/
```

## Case 2: Using HTTP between the pod and the egress GW. Deploy the client inside the mesh to connect to the Nginx server.

We are going to deploy a _sleep_ pod. The project used is _bookinfo_ and this NS must be member of the Service Mesh.

Deploy the sleep application in the bookinfo namespace:
```
oc apply -f sleep/deploy.yaml -n bookinfo
```

Run a curl command to test the connectivity. Since the Istio objects are not created, you'll receive a 502 error:
```
export NGINX_URL=$(oc get route nginx-http -n nginx -o jsonpath='{.spec.host}')
oc exec -n bookinfo -c sleep $(oc get pods -n bookinfo -o NAME | grep sleep | tail -n1) -- watch -n1 curl -vIs $NGINX_URL
```

Update the files under _ossm_HTTP/_ folder with the OCP domain and reate the Istio objects to route the traffic through the Egress Gateway:
```
oc apply -n istio-system -f ossm_HTTP/istio-system/se-nginx.yaml
oc apply -n istio-system -f ossm_HTTP/istio-system/gw-nginx.yaml
oc apply -n istio-system -f ossm_HTTP/istio-system/vs-egress-nginx.yaml
oc apply -n istio-system -f ossm_HTTP/istio-system/dr-egress-nginx.yaml
oc apply -n bookinfo -f ossm_HTTP/bookinfo/dr-sleep-egress.yaml
oc apply -n bookinfo -f ossm_HTTP/bookinfo/vs-sleep-egress.yaml
```

The curl command begins to work properly and returns a 200 status code.

Delete the Istio objects:
```
oc delete -n istio-system -f ossm_HTTP/istio-system/
oc delete -n bookinfo -f ossm_HTTP/bookinfo/
```

## Cleanup

Delete the sleep application from the bookinfo namespace:
```
oc delete -f sleep/deploy.yaml -n bookinfo
```

Delete the Nginx server
```
oc delete project nginx
```
