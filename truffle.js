module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
solc: { optimizer: { enabled: false, runs: 200 } },

  networks: {
   development: {
     host: "localhost",
     port: 8545,
     network_id: "*" // Match any network id
   }
 }
};
