export PATH=../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

ORDERER=orderer.authority.gov:7050

AUTHPEER=peer0.authority.gov
AUTHMSPID="CORE_PEER_LOCALMSPID=AuthorityMSP"
AUTHCFG="CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@authority.gov/msp"

ENT1PEER=peer0.entity1.com
ENT1SPID="CORE_PEER_LOCALMSPID=Entity1MSP"
ENT1CFG="CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@entity1.com/msp"

ENT2PEER=peer0.entity2.com
ENT2SPID="CORE_PEER_LOCALMSPID=Entity2MSP"
ENT2CFG="CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@entity2.com/msp"

CHANNEL=entity1

docker exec -e $AUTHMSPID -e $AUTHCFG $AUTHPEER peer channel create -o $ORDERER -c $CHANNEL -f "/etc/hyperledger/configtx/$CHANNEL.tx"
docker exec -e $AUTHMSPID -e $AUTHCFG $AUTHPEER peer channel join -b "$CHANNEL.block"

docker exec -e $ENT1SPID -e $ENT1CFG $ENT1PEER peer channel fetch newest -o $ORDERER -c $CHANNEL "$CHANNEL.block"
docker exec -e $ENT1SPID -e $ENT1CFG $ENT1PEER peer channel join -b "$CHANNEL.block"

CHANNEL=entity2

docker exec -e $AUTHMSPID -e $AUTHCFG $AUTHPEER peer channel create -o $ORDERER -c $CHANNEL -f "/etc/hyperledger/configtx/$CHANNEL.tx"
docker exec -e $AUTHMSPID -e $AUTHCFG $AUTHPEER peer channel join -b "$CHANNEL.block"

docker exec -e $ENT2SPID -e $ENT2CFG $ENT2PEER peer channel fetch newest -o $ORDERER -c $CHANNEL "$CHANNEL.block"
docker exec -e $ENT2SPID -e $ENT2CFG $ENT2PEER peer channel join -b "$CHANNEL.block"

CHANNEL=shared

docker exec -e $AUTHMSPID -e $AUTHCFG $AUTHPEER peer channel create -o $ORDERER -c $CHANNEL -f "/etc/hyperledger/configtx/$CHANNEL.tx"
docker exec -e $AUTHMSPID -e $AUTHCFG $AUTHPEER peer channel join -b "$CHANNEL.block"

docker exec -e $ENT1SPID -e $ENT1CFG $ENT1PEER peer channel fetch newest -o $ORDERER -c $CHANNEL "$CHANNEL.block"
docker exec -e $ENT1SPID -e $ENT1CFG $ENT1PEER peer channel join -b "$CHANNEL.block"

docker exec -e $ENT2SPID -e $ENT2CFG $ENT2PEER peer channel fetch newest -o $ORDERER -c $CHANNEL "$CHANNEL.block"
docker exec -e $ENT2SPID -e $ENT2CFG $ENT2PEER peer channel join -b "$CHANNEL.block"
