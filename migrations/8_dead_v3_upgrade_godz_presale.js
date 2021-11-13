const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzPresale = artifacts.require('CryptoGodzPresale');
const CryptoGodzPresaleV3 = artifacts.require('CryptoGodzPresaleV3');

module.exports = async function (deployer) {
  // Godz Presale Upgrade
  const existing = await CryptoGodzPresale.deployed();
  const godzPresaleV3 = await upgradeProxy(existing.address, CryptoGodzPresaleV3, { unsafeAllowRenames: true });
  console.log('V3 Upgraded Godz Token Presale ', godzPresaleV3.address);
};