var HnyCoin = artifacts.require("./HNYToken.sol");
var Crowdsale = artifacts.require("./HNYCrowdsale.sol");

module.exports = function(deployer) {
  var owner = web3.eth.accounts[0];
	var wallet = web3.eth.accounts[1];
  // var owner = '0x6f2010D0FBaf8B7Dbc13eE7252FF8594A2Be3C51';
	// var wallet = '0x532691886A05eDc95457BFd5aEDA9b65b5413c83';

  console.log("Owner address: " + owner);
	console.log("Wallet address: " + wallet);

	return deployer.deploy(HnyCoin, { from: owner }).then(function() {
		console.log("HnyCoin address: " + HnyCoin.address);
		return deployer.deploy(Crowdsale, 1522540800, 1530403200, 8400, 6000, wallet, HnyCoin.address, {from: owner}).then(function() {
			console.log("Crowdsale address: " + Crowdsale.address);
			return HnyCoin.deployed().then(function(coin) {
				return coin.owner.call().then(function(owner) {
					console.log("HnyCoin owner : " + owner);
					return coin.transferOwnership(Crowdsale.address, {from: owner}).then(function(txn) {
						console.log("HnyCoin owner was changed: " + Crowdsale.address);
					});
				})
			});
		});
	});
};
