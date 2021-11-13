// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
interface IBEP20PausableUpgradeable is IERC20Upgradeable, IERC20MetadataUpgradeable {
    /**
     * @dev Mint game rewards
     */
    function mint(uint256 rewards_) external;

    /**
     * @dev Set minter role for {Rewards Manager}, {Timelock Manager}.
     */
    function setMinter(address minter_) external;

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
     * @dev Destroys `amount` tokens from the caller.
     */
    function burn(uint256 amount) external;
    
    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() external view returns (uint256);
}