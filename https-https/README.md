# https-https

In this example, the app pod will connect to an external service using HTTPS. For this, we will use an Egress Gateway in **PASSTHROUGH** mode.

The _OCP_APPS_DOMAIN_ is the external domain in which the nginx server will be exposed.

## Deploy the Nginx server with mTLS configuration

Set the external domain in the _[params.env](./params.env)_ file.

Deploying a Nginx Server using mTLS with OpenShift routes.

First create the certificates. Set your domain in the _[certs.sh](./certs/certs.sh)_ script and run for generate the certificates:
```
certs/certs.sh
```

Create the new project:
```
oc new-project nginx-mtls
```

Create the Server certificates:
```
oc create -n nginx-mtls secret generic nginx-ca-certs --from-file=certs/ca.pem
oc create -n nginx-mtls secret generic nginx-server-certs --from-file=tls.crt=./certs/server.pem --from-file=tls.key=./certs/server.key
```

Create the SA for the nginx server:
```
oc create sa nginx
oc adm policy add-scc-to-user anyuid -z nginx
```

Create the Nginx conf:
```
oc create cm nginx-configmap -n nginx-mtls --from-file=nginx.conf=./nginx-deploy/nginx.conf
```

Deploy the Nginx server with mTLS configuration:
```
oc process -f nginx-deploy/nginx.yaml --param-file=params.env --ignore-unknown-parameters | oc apply -f -
```

Finally, expose the nginx-mtls server creating an OpenShift route:
```
oc apply -f nginx-deploy/route-nginx.yaml
```

## Deploy the client inside the mesh to connect to the Nginx server with mTLS. Egress Gateway with Passthrough

We are going to deploy a _sleep_ pod with the TLS certificates. The project used is _bookinfo_.

First, create the secret with the client certificates:
```
oc create secret generic nginx-client-certs -n bookinfo --from-file=tls.crt=./certs/client.pem --from-file=tls.key=./certs/client.key --from-file=ca.crt=./certs/ca.pem
```

Deploy the sleep application in the bookinfo namespace:
```
oc apply -f sleep/deploy.yaml
```

Create the Istio objects to route the traffic through the Egress Gateway:
```
oc apply -n istio-system -f ossm/istio-system/se-nginx-mtls.yaml
oc apply -n istio-system -f ossm/istio-system/gw-nginx-mtls.yaml
oc apply -n istio-system -f ossm/istio-system/vs-egress-nginx-mtls.yaml
# oc apply -n bookinfo -f ossm/bookinfo/dr-sleep-egress.yaml (check if you have already created this DR in this NS)
oc apply -n bookinfo -f ossm/bookinfo/vs-sleep-egress.yaml
```

Check connectivity from sleep pod to the nginx-mtls server throught the Egress Gateway:
```
oc exec $SLEEP-POD-NAME -- curl https://nginx.${OCP_APPS_DOMAIN} --cacert /etc/sleep/tls/ca.crt  --cert /etc/sleep/tls/tls.crt --key /etc/sleep/tls/tls.key -vI
