const { deployProxy } = require('@openzeppelin/truffle-upgrades');

// const CryptoGodz = artifacts.require('CryptoGodzV2');
const CryptoGodzOracle = artifacts.require('CryptoGodzOracle');

module.exports = async function (deployer, network) {
  // const godzToken = await CryptoGodz.deployed();

  if (network === 'bsc') {
    let pancakeV2Pair = '0x2D0BEeb212a8dBE1adBc728F3eE84B1348b44c59';
    console.log({ pancakeV2Pair });

    // CryptoGodz Oracle
    const cryptoGodzOracle = await deployProxy(CryptoGodzOracle, [pancakeV2Pair], { deployer, kind: 'uups' });
    console.log('CryptoGodz Oracle deployed ', cryptoGodzOracle.address);
  }
};