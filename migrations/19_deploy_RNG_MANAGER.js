const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const RngManager = artifacts.require('RngManager');

module.exports = async function (deployer) {
  // Godz Token
  const rngManager = await deployProxy(RngManager, [], { deployer, kind: 'uups' });
  console.log('Deployed RNG Manager', rngManager.address);
};