'use strict';

var fc = require('fabric-client');
var path = require('path');
var csv = require('csvtojson');

var fabric_client = new fc();

var currentMSP = process.argv[2];
var currentUserID = process.argv[3];
var currentChannel = process.argv[4];
var currentPeerAddr = process.argv[5];

// setup the fabric network
var channel = fabric_client.newChannel(currentChannel);
var peer = fabric_client.newPeer(currentPeerAddr);
channel.addPeer(peer);
var order = fabric_client.newOrderer('grpc://localhost:7050')
channel.addOrderer(order);
var store_path = path.join(__dirname, 'hfc-key-store', currentMSP);
var dataPath = "./seed-data/";

console.log(store_path)

async function getUserContext(state_store) {
	// assign the store to the fabric client
	fabric_client.setStateStore(state_store);
	var crypto_suite = fc.newCryptoSuite();
	// use the same location for the state store (where the users' certificate are kept)
	// and the crypto store (where the users' keys are kept)
	var crypto_store = fc.newCryptoKeyStore({path: store_path});
	crypto_suite.setCryptoKeyStore(crypto_store);
	fabric_client.setCryptoSuite(crypto_suite);

	// get the enrolled user from persistence, this user will sign all requests
	return fabric_client.getUserContext(currentUserID, true);
}

async function createProposal(user, data) {
	if (!user || !user.isEnrolled()) {
		throw new Error('Failed to get user.... run registerUser.js');
	}

	return channel.sendTransactionProposal({
		chaincodeId: 'entries',
		fcn: 'add',
		args: [data],
		chainId: currentChannel,
		txId: fabric_client.newTransactionID()
	});
}

async function sendTransaction(results) {
	var proposalResponses = results[0];
	var proposal = results[1];
	if (!proposalResponses || !proposalResponses[0].response || proposalResponses[0].response.status != 200) {
		throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
	}

	return channel.sendTransaction({
		proposalResponses: proposalResponses,
		proposal: proposal
	});
}

function sendData(user) {
	csv({
		quote:'"',
		delimiter: ',',
		trim: true,
		checkType: true
	}).fromFile(dataPath + currentChannel + ".csv").on('json', (obj) => {

		createProposal(user, JSON.stringify(obj))
		.then(sendTransaction)
		.then(result => console.log(result.status))
		.catch(error => console.log(error));
	})
	.on('done', (err) => {
		if (err)
			console.log(err);
	})
}

fc.newDefaultKeyValueStore({ path: store_path})
	.then(getUserContext)
	.then(sendData);
