// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface ICryptoGodzPresaleVault {
    function transfer(address to_, uint256 amount_) external;
    function setupAdminRole(address address_) external;
}