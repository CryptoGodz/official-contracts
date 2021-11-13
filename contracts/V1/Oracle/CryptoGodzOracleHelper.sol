// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../CgConstants.sol";
import "./ICryptoGodzOracle.sol";

library CryptoGodzOracleHelper {
    function oracle(uint256 value) internal view returns (uint256) {
        ICryptoGodzOracle _oracle = ICryptoGodzOracle(CgConstants.ORACLE_ADDRESS);
        uint256 newPricePerBNB = _oracle.consult(CgConstants.BNB, 1);
        uint256 priceChange = (newPricePerBNB/CgConstants.INITIAL_GODZ_PRICE);
        return value * priceChange;
    }

    function oracleReverse(uint256 value) internal view returns (uint256) {
        ICryptoGodzOracle _oracle = ICryptoGodzOracle(CgConstants.ORACLE_ADDRESS);
        uint256 newPricePerBNB = _oracle.consult(CgConstants.BNB, 1);
        uint256 bnbAmount = newPricePerBNB * (value / uint256(10**18));
        return bnbAmount;
    }
}