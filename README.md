# rhossm-egress-examples
Some examples for egress gateway usage.

1. Adding Bookinfo and Bookinfo-custom consuming external MySQL DDBB. Testing TCP egress traffic in this [lab](./bookinfo-mysql-ddbb/)

2. Adding greeter server and greeter client for testing gRPC in RHOSSM. The greeter client will be deployed inside the mesh and the greeter server will be outside the mesh. An Egress gateway will be used to reach the greeter server via mTLS [lab](./rhossm-grpc-example/)