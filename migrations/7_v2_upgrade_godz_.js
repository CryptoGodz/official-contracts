const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodz = artifacts.require('CryptoGodz');
const CryptoGodzV2 = artifacts.require('CryptoGodzV2');

module.exports = async function (deployer) {
  // Godz Presale Upgrade
  const existing = await CryptoGodz.deployed();
  const godzV2 = await upgradeProxy(existing.address, CryptoGodzV2);
  console.log('V3 Upgraded Godz Token ', godzV2.address);
};