// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../../V1/CryptoGodzStructs.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./ICryptoGodzV2.sol";

import "@pancakeswap2/pancake-swap-core/contracts/interfaces/IPancakeFactory.sol";
import "@theanthill/pancake-swap-periphery/contracts/interfaces/IPancakeRouter02.sol";
import "../../V1/Oracle/PancakeLibrary.sol";

contract CryptoGodzV2 is Initializable, ContextUpgradeable, OwnableUpgradeable, UUPSUpgradeable, AccessControlEnumerableUpgradeable, PausableUpgradeable, ERC20Upgradeable, ICryptoGodzV2 {
    using SafeMathUpgradeable for uint256;
    
    address public pancakeV2Pair;
    IPancakeRouter02 public pancakeRouterV2;

    uint8 private _decimals;
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
		__CryptoGodz_init_unchained(decimals_, initialSupply_, cap_);
	}

    function __CryptoGodz_init_unchained(uint8 decimals_, uint256 initialSupply_, uint256 cap_) internal initializer {
        require(cap_ > 0, "BEP20Capped: cap is 0");
        _cap = cap_;

        _decimals = decimals_;

        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        setPauser(owner());

        _mint(owner(), initialSupply_);
    }

    /**
     * @dev migrate tokens
     */
    function migrateData(address[] memory destinations, uint256[] memory values) external override onlyOwner {
        require(destinations.length == values.length, "invalid input length");
 
        for (uint i = 0; i < destinations.length; i++) {
            require(destinations[i] != address(0), "recipient is required");
            _transfer(address(this), destinations[i], values[i]);
        }
    }
    
    /**
     * @dev create pair
     */
    function createPair() external override onlyOwner returns(address) {
        pancakeRouterV2 = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        if (pancakeV2Pair == address(0)) {
            // create pair
            pancakeV2Pair = IPancakeFactory(
                pancakeRouterV2.factory()
            ).createPair(address(this), pancakeRouterV2.WETH());
        }

        return pancakeV2Pair;
    }
    
    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view override returns (uint256) {
        return _cap;
    }

    /**
     * @dev Mint game rewards without exceeding token supply cap
     */
    function mint(uint256 rewards_) external override onlyOwner {
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
     * @dev Set minter role for {Rewards Manager}, {Timelock Manager}.
     */
    function setPauser(address pauser_) public override onlyOwner {
        _setupRole(CryptoGodzStructs.PAUSER_ROLE, pauser_);
    }
    
    /**
     * @dev Pauses all token transfers.
     */
    function pause() public override onlyRole(CryptoGodzStructs.PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     */
    function unpause() public override onlyRole(CryptoGodzStructs.PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev See {BEP20-transfer}.
     */
    function transfer(address recipient, uint256 amount) public virtual override(ERC20Upgradeable, IERC20Upgradeable) returns (bool) {
        return super.transfer(recipient, amount);
    }

    /**
     * @dev See {BEP20-transferFrom}.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override(ERC20Upgradeable, IERC20Upgradeable) returns (bool) {
        require(allowance(sender, _msgSender()) >= amount, "BEP20: transfer amount exceeds allowance");
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {
        require(allowance(_msgSender(), spender) >= subtractedValue, "BEP20: decreased allowance below zero");
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(balanceOf(sender) >= amount, "BEP20: transfer amount exceeds balance");
        super._transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "BEP20: mint to the zero address");
        super._mint(account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     */
    function _burn(address account, uint256 amount) internal virtual override {
        require(account != address(0), "BEP20: burn from the zero address");

        require(balanceOf(account) >= amount, "BEP20: burn amount exceeds balance");
        super._burn(account, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     */
    function _approve(address owner_, address spender, uint256 amount) internal virtual override {
        require(owner_ != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        super._approve(owner_, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted from the caller's allowance.
     */
    function _burnFrom(address account, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "BEP20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes minting and burning.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

}