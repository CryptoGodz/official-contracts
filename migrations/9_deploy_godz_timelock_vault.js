const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzPresaleV3 = artifacts.require('CryptoGodzPresaleV3');
const CryptoGodzTimelockVault = artifacts.require('CryptoGodzTimelockVault');

module.exports = async function (deployer) {
  // Godz Timelock Vault
  const godzTimelockVault = await deployProxy(CryptoGodzTimelockVault, ["0x0Ab1Ad868cf248438C14aa1795B9085839bc202a"], { deployer, kind: 'uups' });
  console.log('Deployed Godz Timelock Vault', godzTimelockVault.address);

  // Grant Presale address as DEFAULT_ADMIN_ROLE
  const godzPresaleV3 = await CryptoGodzPresaleV3.deployed();
  await godzTimelockVault.grantRole((await godzTimelockVault.DEFAULT_ADMIN_ROLE()), godzPresaleV3.address);
  console.log('Godz Presale added as Timelock Vault contract admin:', godzPresaleV3.address);
  
  await godzPresaleV3.setVestingTime(30);
  console.log(`Vesting time set at every ${30} days`);

  await godzPresaleV3.setVestingAmount(20);
  console.log(`Vesting amount set at ${20}%`);

  await godzPresaleV3.setTimelockVault(godzTimelockVault.address);
  console.log(`Set presale timelock vault: `, godzTimelockVault.address);
};