const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzPresale = artifacts.require('CryptoGodzPresale');
const CryptoGodzPresaleV4 = artifacts.require('CryptoGodzPresaleV4');

module.exports = async function (deployer) {
  // Godz Presale Upgrade
  const existing = await CryptoGodzPresale.deployed();
  const godzPresaleV4 = await upgradeProxy(existing.address, CryptoGodzPresaleV4, { unsafeAllowRenames: true });
  console.log('V4 Upgraded Godz Token Presale ', godzPresaleV4.address);
};