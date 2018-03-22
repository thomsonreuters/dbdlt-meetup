if [ ! -d node_modules ]; then
  npm install
fi

node enrollAdmin.js AuthorityMSP http://localhost:7054 ca.authority.gov
node enrollAdmin.js Entity1MSP http://localhost:8054 ca.entity1.com
node enrollAdmin.js Entity2MSP http://localhost:9054 ca.entity2.com

sleep 2

node registerUser.js AuthorityMSP http://localhost:7054 user1
node registerUser.js Entity1MSP http://localhost:8054 user1
node registerUser.js Entity2MSP http://localhost:9054 user1

sleep 2

node loadData.js Entity1MSP user1 entity1 grpc://localhost:8051
node loadData.js Entity2MSP user1 entity2 grpc://localhost:9051
node loadData.js Entity1MSP user1 shared grpc://localhost:8051