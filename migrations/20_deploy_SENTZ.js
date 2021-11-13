const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const RngManager = artifacts.require('RngManager');
const CryptoGodzSentz = artifacts.require('CryptoGodzSentz');

// CryptoGodzSentz NFT
const metaData = {
  name: "CryptoGodz Sentz",
  symbol: "CG Sentz"
};

module.exports = async function (deployer) {
  // CryptoGodzSentz NFT
  const rngManager = await RngManager.deployed();
  const cgSentz = await deployProxy(CryptoGodzSentz, [metaData.name, metaData.symbol, rngManager.address], { deployer, kind: 'uups' });
  console.log('Deployed CryptoGodzSentz', cgSentz.address);

  let role = await rngManager.DEFAULT_ADMIN_ROLE();
  rngManager.grantRole(role, cgSentz.address);
  console.log('RNG Manager grant admin role to SENT NFT Contract: ', cgSentz.address);
};