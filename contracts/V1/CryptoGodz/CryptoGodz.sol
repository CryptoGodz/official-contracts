// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../CryptoGodzStructs.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../BEP20Pausable/BEP20PausableUpgradeable.sol";

contract CryptoGodz is Initializable, UUPSUpgradeable, BEP20PausableUpgradeable {
    using SafeMathUpgradeable for uint256;
    
    uint256 private _cap;

    /// @custom:oz-upgrades-unsafe-allow constructor
	constructor() initializer {}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

	function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 cap_
    )
    public initializer {
		__CryptoGodz_init(name_, symbol_, decimals_, initialSupply_, cap_);
	}

	function __CryptoGodz_init(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 cap_
    ) public initializer {
		__ERC1967Upgrade_init_unchained();
		__UUPSUpgradeable_init_unchained();
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
		__Ownable_init_unchained();
        __Pausable_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
        __BEP20_init_unchained(decimals_, initialSupply_);
		__CryptoGodz_init_unchained(cap_);
	}

	function __CryptoGodz_init_unchained(uint256 cap_) public initializer {
        require(cap_ > 0, "BEP20Capped: cap is 0");
        _cap = cap_;
	}

    /**
     * @dev Mint game rewards without exceeding token supply cap
     */
    function mint(uint256 rewards_) external override onlyRole(CryptoGodzStructs.MINTER_ROLE) {
        require(totalSupply().add(rewards_) <= cap(), "BEP20Capped: cap exceeded");
        _mint(owner(), rewards_);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     */
    function burn(uint256 amount) external override {
        _burn(_msgSender(), amount);
    }
    
    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view override returns (uint256) {
        return _cap;
    }
}