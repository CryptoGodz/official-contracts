// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../CryptoGodzStructs.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./IBEP20PausableUpgradeable.sol";

abstract contract BEP20PausableUpgradeable is Initializable, ContextUpgradeable, OwnableUpgradeable, AccessControlEnumerableUpgradeable, PausableUpgradeable, IBEP20PausableUpgradeable, ERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    uint8 private _decimals;

    /**
     * @dev Sets the values for {name}, {symbol}, {decimals} and {initialSupply}.
     */
    function __BEP20_init(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply_) internal initializer {
		__Ownable_init_unchained();
        __Pausable_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
        __BEP20_init_unchained(decimals_, initialSupply_);
    }

    function __BEP20_init_unchained(uint8 decimals_, uint256 initialSupply_) internal initializer {
        _decimals = decimals_;

        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        setMinter(owner());
        setPauser(owner());

        _mint(owner(), initialSupply_);
    }

    /**
     * @dev Set minter role for {Rewards Manager}, {Timelock Manager}.
     */
    function setMinter(address minter_) public override onlyOwner {
        _setupRole(CryptoGodzStructs.MINTER_ROLE, minter_);
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