const BN = require('bn.js');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzV2 = artifacts.require('CryptoGodzV2');

// Godz Token
const metaData = {
  name: "CryptoGodz",
  symbol: "GODZ",
  decimals: 18,
  initialSupply: 74000000,
  cap: 74000000,
};

module.exports = async function (deployer) {
  // Godz Token
  const godzToken = await deployProxy(CryptoGodzV2, [metaData.name, metaData.symbol, metaData.decimals, _toPowrdBN(metaData.initialSupply), _toPowrdBN(metaData.cap)], { deployer, kind: 'uups' });
  console.log('Deployed Godz Token V2', godzToken.address);

  // convert to big int scaled with decimals
  function _toPowrdBN(x) {
    return new BN(x).mul(new BN(10).pow(new BN(metaData.decimals)));
  }
};