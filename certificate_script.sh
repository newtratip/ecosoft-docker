#!/bin/bash
HOST=127.0.0.1

# Create directory cert for store file
mkdir cert && cd cert

###################################################################
# For docker daemon’s host machine
# Generate CA private key
echo "=============== Generate CA private key ==============="
openssl genrsa -aes256 -out ca-key.pem 4096
echo ""

# Generate CA public key
echo "=============== Generate CA public key ==============="
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
echo ""

# Generate server key
echo "=============== Generate server key ==============="
openssl genrsa -out server-key.pem 4096
echo ""

# Generate certificate signing request
echo "=============== Generate certificate signing request ==============="
openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr
echo ""

# Allow connection using 10.10.10.20 and 127.0.0.1
echo "=============== Generate extfile ==============="
echo subjectAltName = DNS:$HOST,IP:10.10.10.20,IP:127.0.0.1 >> extfile.cnf

# Set the docker daemon key’s extended usage attributes to be used only for server authentication
echo extendedKeyUsage = serverAuth >> extfile.cnf
echo ""

# Generate the signed certificate
echo "=============== Generate the signed certificate ==============="
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf
echo ""

###################################################################
# For client authentication
# Generate client key
echo "=============== Generate client key ==============="
openssl genrsa -out key.pem 4096
echo ""

# Generate certificate signing request
echo "=============== Generate certificate signing request ==============="
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo ""

# To make the key suitable for client authentication, create a new extensions config file
echo "=============== Generate extfile-client ==============="
echo extendedKeyUsage = clientAuth > extfile-client.cnf
echo ""

# Generate the signed certificate
echo "=============== Generate the signed certificate ==============="
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile-client.cnf

sudo mkdir /.cert && sudo cp ../cert/{ca,server-cert,server-key,cert,key}.pem /.cert && sudo rm -r ../cert
