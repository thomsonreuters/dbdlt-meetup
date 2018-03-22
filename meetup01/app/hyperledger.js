'use strict';
var fab_client = require('fabric-client'),
path = require('path');


async function execute(config, chan, request) {
  var client = new fab_client();
  var channel = client.newChannel(chan);
  var peer = client.newPeer(config.peer);
  channel.addPeer(peer);

  // only needed for add, update, delete
  var orderer = client.newOrderer(config.orderer);
  channel.addOrderer(orderer);

  var store_path = path.join('../init', 'hfc-key-store', config.mspid);

  return fab_client.newDefaultKeyValueStore({path: store_path})
    .then((state) => {
      client.setStateStore(state);
      var crypto_suite = fab_client.newCryptoSuite();
      var crypto_store = fab_client.newCryptoKeyStore({ path: store_path });
      crypto_suite.setCryptoKeyStore(crypto_store);
      client.setCryptoSuite(crypto_suite);
      return client.getUserContext(config.name, true);
    })
    .then(user => {
      if (!user || !user.isEnrolled()) {
        return { "error": "failed to load user" };
      }
      return channel.queryByChaincode(request);
    })
    .then((response) => {
      if (response && response.length == 1) {
        if (response[0] instanceof Error) {
          return { "error": query_responses[0] };
        } else {
          return JSON.parse(response[0].toString());
        }
      } else {
        return { "error": "No payloads were returned from query" };
      }
    }).catch((err) => {
      return { "error": err }; 
    });
};

exports.history = function(config, chan, id) {
  const request = {
    chaincodeId: 'entries',
    fcn: 'history',
    args: [id]
  };

  return execute(config, chan, request);
}

exports.all = function(config, chan) {
  const request = {
    chaincodeId: 'entries',
    fcn: 'all',
    args: [""]
  };

  return execute(config, chan, request);
};

exports.query = function(config, chan, stmt) {
  const request = {
    chaincodeId: 'entries',
    fcn: 'query',
    args: [stmt]
  };

  return execute(config, chan, request);
};

exports.get = function(config, chan, id) {
  const request = {
    chaincodeId: 'entries',
    fcn: 'get',
    args: [id]
  };

  return execute(config, chan, request);
};

exports.sendTransaction = function(fcn, config, chan, id, data) {
  var client = new fab_client();
  var channel = client.newChannel(chan);
  var peer = client.newPeer(config.peer);
  channel.addPeer(peer);
  var orderer = client.newOrderer(config.orderer);
  channel.addOrderer(orderer);

  //return getUserContext(client, config.mspid, config.name)
  var store_path = path.join('../init', 'hfc-key-store', config.mspid);
  return fab_client.newDefaultKeyValueStore({path: store_path})
  .then((state) => {
    client.setStateStore(state);
    var crypto_suite = fab_client.newCryptoSuite();
    var crypto_store = fab_client.newCryptoKeyStore({ path: store_path });
    crypto_suite.setCryptoKeyStore(crypto_store);
    client.setCryptoSuite(crypto_suite);
    return client.getUserContext(config.name, true);
  })
  .then((user) => {
      if (!user || !user.isEnrolled()) {
        throw new Error("failed to load user");
      }

      const request = {
        chaincodeId: 'entries',
        chainId: config.channel,
		    fcn: fcn,
		    args: [id, JSON.stringify(data)],
		    txId: client.newTransactionID()
      };

      return channel.sendTransactionProposal(request);
    }).then((result) => {
      var responses = result[0];
      var proposal = result[1];
      if (!responses || !responses[0].response || responses[0].response.status != 200) {
        throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
      }

      return channel.sendTransaction({
        proposalResponses: responses,
        proposal: proposal
      });
    }).then((result) => {
      if (result.status !== "SUCCESS") {
        throw new Error('Add failed.')
      }
      return { "success": true }
    }).catch((err) => {
      return { "success": false, "message" : err.toString() }
    });;
};
