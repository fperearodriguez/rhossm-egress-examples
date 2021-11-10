# rhossm-egress-examples
Some examples for egress gateway usage.

1. Adding Bookinfo and Bookinfo-custom consuming external MySQL DDBB. Testing TCP egress traffic in this [lab](./bookinfo-mysql-ddbb/)

2. Adding greeter server and greeter client for testing gRPC in RHOSSM. The greeter client will be deployed inside the mesh and the greeter server will be outside the mesh. An Egress gateway will be used to reach the greeter server via mTLS [lab](./rhossm-grpc-example/)

3. Adding a nginx server with mTLS for testing the Egress Gateway in Passthrough mode. The nginx-mtls server will be outside the mesh, the application will be deployed in the mesh (sleep sample app). An Egress gateway in Passthrough mode will be used to reach the nginx server via mTLS [lab](./https-https/)

4. Adding a nginx server with mTLS for testing the Egress Gateway with TLS origination. The nginx-mtls server will be outside the mesh, the application will be deployed in the mesh (sleep sample app). An Egress gateway with TLS origination mode will be used to reach the nginx server via mTLS [lab](./http-https/)

5. Adding a bookinfo application using an external MySQL database. The bookinfo application will be deployed in two different namespaces: front and back [lab](./bookinfo-mysql-multiple-ns/)

6. Adding a nginx server listening on HTTP port. Thus, a pod deployed inside the mesh will connect to this Nginx server through an Egress Gateway [lab](./http-http/)