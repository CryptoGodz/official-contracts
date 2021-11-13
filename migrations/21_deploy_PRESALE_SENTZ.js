const web3 = require('web3');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const CryptoGodzSentz = artifacts.require('CryptoGodzSentz');
const CryptoGodzPresaleNFT = artifacts.require('CryptoGodzPresaleNFT');

// CryptoGodzSentz NFT
const metaData = {
  price: web3.utils.toWei(String(0.037026066350710900)),
  nftLimit: web3.utils.toWei(String(15000)),
  // wallet: "0x0Ab1Ad868cf248438C14aa1795B9085839bc202a",
  wallet: "0x3d98F27493312acae750E98e1B7B64694411e7a2",
};

module.exports = async function (deployer) {
  console.log(metaData)
  
  // CryptoGodzSentz NFT
  const _sentzNFT = await CryptoGodzSentz.deployed();
  
  const _presaleSentzNFT = await deployProxy(CryptoGodzPresaleNFT, [
    metaData.price, metaData.nftLimit, metaData.wallet, _sentzNFT.address
  ], { deployer, kind: 'uups' });
  console.log('Deployed CryptoGodzSentz Presale', _presaleSentzNFT.address);
  
  let role = await _sentzNFT.DEFAULT_ADMIN_ROLE();
  _sentzNFT.grantRole(role, _presaleSentzNFT.address);
  console.log('Sentz Contract: grant admin role to SENT NFT PRESALE Contract: ', _presaleSentzNFT.address);
};
