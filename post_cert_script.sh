mkdir post_cert
cd post_cert
echo "============= rootCA ============="
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -key rootCA.key -days 10000 -out rootCA.crt
echo "============= Server ============="
mkdir server
cd server
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -CA ../rootCA.crt -CAkey ../rootCA.key -CAcreateserial -out server.crt -days 5000
cd ..
echo "============= Client ============="
mkdir client
cd client
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr
openssl x509 -req -in client.csr -CA ../rootCA.crt -CAkey ../rootCA.key -CAcreateserial -out client.crt -days 5000
cd ..
chmod 600 server/server.key
chmod 600 client/client.key