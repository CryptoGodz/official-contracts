// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "../CryptoGodzStructs.sol";

interface ICryptoGodzTimelockVault {
    /**
     * @return the amount of timelocked tokens.
     */
    function getTotalTimeLockedTokens() external view returns (uint256);

    /**
     * @return the amount of timelocked tokens per group.
     */
    function getDevTimeLockedTokens() external view returns (uint256);

    /**
     * @return the amount of timelocked tokens per group.
     */
    function getSeedInvestorsTimeLockedTokens() external view returns (uint256);
    
    /**
     * @return the amount of timelocked tokens per group.
     */
    function getAirdropTimeLockedTokens() external view returns (uint256);
    
    /**
     * @return the amount of timelocked tokens per group.
     */
    function getRewardsTimeLockedTokens() external view returns (uint256);

    /**
     * @return the amount of timelocked tokens of single account from keccak256("DEV").
     */
    function getTimeLockedTokensByGroup(string memory group) external view returns (uint256);

    /**
     * @return the amount of timelocked tokens of single account.
     */
    function getAccountTimeLockedTokens(string memory group, address account) external view returns (CryptoGodzStructs.TimelockData memory);

    /**
     * Add a timelock rule
     * addTimelock(keccak256("DEV"), {address}, [...uint256])
     */
    function addTimelock(
        string memory group,
        address benificiary,
        uint256 tokenAmount,
        uint256 lastReleased,
        uint256 releaseTimeFrequency,
        uint256 releaseAmount
    ) external;

    function claimTokens(string memory group, address benificiary) external;
}