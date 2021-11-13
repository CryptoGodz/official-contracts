// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library CgConstants {
    // Wrapped BNB address
    address constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // todo: redeploy oracle and update oracle address
    address constant ORACLE_ADDRESS = 0x6f18bf6339650b26C3F079F38275991Db98c30D9;

    // todo: adjust on launch day
    uint256 constant INITIAL_GODZ_PRICE = (uint256(2762667) / uint256(10));
}