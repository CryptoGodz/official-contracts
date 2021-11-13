const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzV2 = artifacts.require('CryptoGodzV2');
const CryptoGodzTimelockVault = artifacts.require('CryptoGodzTimelockVault');
const CryptoGodzTimelockVaultV2 = artifacts.require('CryptoGodzTimelockVaultV2');

module.exports = async function (deployer) {
  const newGodzToken = await CryptoGodzV2.deployed();
  const existing = await CryptoGodzTimelockVault.deployed();

  // Godz Timelock Vault
  const godzTimelockVaultV2 = await upgradeProxy(existing.address, CryptoGodzTimelockVaultV2);
  console.log('Deployed Godz Timelock Vault V2', godzTimelockVaultV2.address);
  
  // set new godz contract address 
  await godzTimelockVaultV2.adminSetNewGodzToken(newGodzToken.address);
  console.log('Timelock Vault V2: Updated to new Godz token address', newGodzToken.address);
};