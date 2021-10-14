#!/bin/bash

# Changes these CN's to match your hosts in your environment if needed.
SERVER_CN=nginx.${OCP_APPS_DOMAIN}
CLIENT_CN=client-cn# Used when doing mutual TLS
CURRENT_DIR=$(pwd)

echo "Create CA"
## generate rootca private key
openssl genrsa  -out $CURRENT_DIR/certs/cakey.pem 4096

## generate rootCA certificate
openssl req -new -x509 -days 3650  -config $CURRENT_DIR/certs/cert.conf  -key $CURRENT_DIR/certs/cakey.pem -out $CURRENT_DIR/certs/ca.pem

## Verify the rootCA certificate content and X.509 extensions
openssl x509 -noout -text -in $CURRENT_DIR/certs/ca.pem

echo "Client cert"
openssl genrsa -out $CURRENT_DIR/certs/client.key 4096
openssl req -new -key $CURRENT_DIR/certs/client.key -out $CURRENT_DIR/certs/client.csr -config $CURRENT_DIR/certs/cert.conf
openssl x509 -req -in $CURRENT_DIR/certs/client.csr -CA $CURRENT_DIR/certs/ca.pem -CAkey $CURRENT_DIR/certs/cakey.pem -out $CURRENT_DIR/certs/client.pem -CAcreateserial -days 365 -sha256 -extfile $CURRENT_DIR/certs/client_cert_ext.conf

echo "Server cert"
openssl genrsa -out $CURRENT_DIR/certs/server.key 4096
openssl req -new -key $CURRENT_DIR/certs/server.key -out $CURRENT_DIR/certs/server.csr -config $CURRENT_DIR/certs/cert.conf
openssl x509 -req -in $CURRENT_DIR/certs/server.csr -CA $CURRENT_DIR/certs/ca.pem -CAkey $CURRENT_DIR/certs/cakey.pem -out $CURRENT_DIR/certs/server.pem -CAcreateserial -days 365 -sha256 -extfile $CURRENT_DIR/certs/server_cert_ext.conf