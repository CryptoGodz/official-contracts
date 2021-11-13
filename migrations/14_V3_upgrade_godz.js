const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzV2 = artifacts.require('CryptoGodzV2');
const CryptoGodzV3 = artifacts.require('CryptoGodzV3');

module.exports = async function (deployer) {
  // Godz Presale Upgrade
  const existing = await CryptoGodzV2.deployed();
  const godzV3 = await upgradeProxy(existing.address, CryptoGodzV3);
  console.log('V3 Upgraded Godz Token ', godzV3.address);
};