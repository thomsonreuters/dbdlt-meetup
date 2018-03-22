export PATH=../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
mkdir config

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile NetworkGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel artifacts
configtxgen -profile Entity1 -outputCreateChannelTx "./config/entity1.tx" -channelID entity1
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

configtxgen -profile Entity2 -outputCreateChannelTx "./config/entity2.tx" -channelID entity2
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

configtxgen -profile Shared -outputCreateChannelTx "./config/shared.tx" -channelID shared
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

cd ..