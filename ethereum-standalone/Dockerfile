FROM alpine:latest

# Copy build files.
ADD ethereum /root/.ethereum

# Install dependencies and init node.
RUN sh /root/.ethereum/build.sh && \
    geth init /root/.ethereum/genesis.json

# Standard Ethreum ports.
EXPOSE 8545 8546 30303 30303/udp

# Start node in a stand alone test mode mode.
ENTRYPOINT geth --networkid 39 --nodiscover --maxpeers 0 --rpc --rpcaddr "0.0.0.0" --rpccorsdomain "*" --rpcapi personal,web3,eth,net,rpc --mine --minerthreads 8
