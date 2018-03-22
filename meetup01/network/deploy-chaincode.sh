

CHAINCODE=acme.com/entries
ORDERER=orderer.authority.gov:7050

CPA="CORE_PEER_ADDRESS=peer0.authority.gov:7051"
CPL="CORE_PEER_LOCALMSPID=AuthorityMSP"
CPM="CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/authority.gov/users/Admin@authority.gov/msp"

CPA1="CORE_PEER_ADDRESS=peer0.entity1.com:7051"
CPL1="CORE_PEER_LOCALMSPID=Entity1MSP"
CPM1="CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/entity1.com/users/Admin@entity1.com/msp"

CPA2="CORE_PEER_ADDRESS=peer0.entity2.com:7051"
CPL2="CORE_PEER_LOCALMSPID=Entity2MSP"
CPM2="CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/entity2.com/users/Admin@entity2.com/msp"

docker exec -e $CPA -e $CPL -e $CPM cli peer chaincode install -n entries -v 0.1 -p $CHAINCODE
sleep 5

docker exec -e $CPA -e $CPL -e $CPM cli peer chaincode instantiate -o $ORDERER -C entity1 -n entries -v 0.1 -c '{"Args":[""]}'
docker exec -e $CPA -e $CPL -e $CPM cli peer chaincode instantiate -o $ORDERER -C entity2 -n entries -v 0.1 -c '{"Args":[""]}'
docker exec -e $CPA -e $CPL -e $CPM cli peer chaincode instantiate -o $ORDERER -C shared -n entries -v 0.1 -c '{"Args":[""]}'

docker exec -e $CPA1 -e $CPL1 -e $CPM1 cli peer chaincode install -n entries -v 0.1 -p $CHAINCODE
sleep 5
# Query forces a ccenv node to be created for the peer. Why does this happen? Instantiate fails otherwise.
docker exec -e $CPA1 -e $CPL1 -e $CPM1 cli peer chaincode query -o $ORDERER -C entity1 -n entries -v 0.1 -c '{"Args":["query", "{}"]}'


docker exec -e $CPA2 -e $CPL2 -e $CPM2 cli peer chaincode install -n entries -v 0.1 -p $CHAINCODE
sleep 5
# Query forces a ccenv node to be created for the peer. Why does this happen? Instantiate fails otherwise.
docker exec -e $CPA2 -e $CPL2 -e $CPM2 cli peer chaincode query -o $ORDERER -C entity2 -n entries -v 0.1 -c '{"Args":["query", "{}"]}'

