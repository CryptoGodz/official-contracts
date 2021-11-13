// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

interface ICryptoGodzV2 is IERC20MetadataUpgradeable  {
    /**
     * @dev Set minter role for {Rewards Manager}, {Timelock Manager}.
     */
    function setPauser(address pauser_) external;
    
    /**
     * @dev Pauses all token transfers.
     */
    function pause() external;

    /**
     * @dev Unpauses all token transfers.
     */
    function unpause() external;
    
    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() external view returns (uint256);

    /**
     * @dev Mint game rewards without exceeding token supply cap
     */
    function mint(uint256 rewards_) external;

    /**
     * @dev Destroys `amount` tokens from the caller.
     */
    function burn(uint256 amount) external;
    
    function migrateData(address[] memory destinations, uint256[] memory values) external;

    /**
     * @dev create pair
     */
    function createPair() external returns(address);
}