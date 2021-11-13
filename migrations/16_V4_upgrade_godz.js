const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzV2 = artifacts.require('CryptoGodzV2');
const CryptoGodzV4 = artifacts.require('CryptoGodzV4');

module.exports = async function (deployer) {
  // Godz Presale Upgrade
  const existing = await CryptoGodzV2.deployed();
  const godzV4 = await upgradeProxy(existing.address, CryptoGodzV4);
  console.log('V4 Upgraded Godz Token ', godzV4.address);
};