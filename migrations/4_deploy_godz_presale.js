const BN = require('bn.js');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzPresale = artifacts.require('CryptoGodzPresale');

// Godz Token Presale
const presaleMetaData = {
  rate:  40833,
  wallet: "0x0Ab1Ad868cf248438C14aa1795B9085839bc202a",
  cap: 32666666,
  tokenDecimals: 18
};

module.exports = async function (deployer) {
  // Godz Token Presale
  const godzTokenPresale = await deployProxy(CryptoGodzPresale, [
    _toPowrdBN(presaleMetaData.rate),
    presaleMetaData.wallet,
    _toPowrdBN(presaleMetaData.cap),
    "0x0Ab1Ad868cf248438C14aa1795B9085839bc202a",
    "0x0Ab1Ad868cf248438C14aa1795B9085839bc202a"
  ], { deployer, kind: 'uups' });
  console.log('Deployed Godz Token Presale', godzTokenPresale.address);

  // convert to big int scaled with decimals
  function _toPowrdBN(x) {
    return new BN(x).mul(new BN(10).pow(new BN(presaleMetaData.tokenDecimals)));
  }
};