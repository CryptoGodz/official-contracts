// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../CgEnums.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../NFTs/interfaces/ICryptoGodzSentz.sol";

/**
 * @title CryptoGodz Presale
 */
contract CryptoGodzPresaleNFT is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    bool private _initialized;

    /// @custom:oz-upgrades-unsafe-allow constructor
	constructor() initializer {}

	function initialize(
        uint256 rate_,
        uint256 cap_,
        address payable wallet_,
        ICryptoGodzSentz sentzNFT_
    )
    public initializer {
        require(!_initialized, "Contract instance has already been initialized");
        _initialized = true;

		__Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();

        require(rate_ > 0, "CryptoGodzPresale: price is 0");
        require(wallet_ != address(0), "CryptoGodzPresale: wallet is the zero address");
        require(address(sentzNFT_) != address(0), "CryptoGodzPresale: SentzNFT is the zero address");

        _rate = rate_;
        _cap = cap_;
        _wallet = wallet_;
        _closed = true;

        _sentzNFT = sentzNFT_;
	}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // The nft being sold
    ICryptoGodzSentz private _sentzNFT;

    // Address where funds are collected
    address payable private _wallet;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 private _rate;

    // Amount of wei raised
    uint256 private _weiRaised;

    uint256 private _soldNfts;

    uint256 private _cap;
    
    bool private _closed;

    /**
     * Event for token purchase logging
     */
    event NFTPurchased(address indexed purchaser);
    
    event PresaleOpened();
    event PresaleClosed();
    event SetRate();

    /**
     * @dev Reverts if presale is closed
     */
    modifier whenOnlyOpened {
        require(!isClosed(), "Presale: is closed.");
        _;
    }

    /**
     * @dev Reverts if presale is closed
     */
    modifier whenOnlyClosed {
        require(isClosed(), "Presale: is not yet closed.");
        _;
    }
    
    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyNFT. Consider calling
     * buyNFT directly when purchasing tokens from a contract.
     */
    receive() external payable {
        buyNFT(_msgSender());
    }

    /**
     * @dev Pauses all token transfers.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Closes the presale.
     */
    function open() external onlyOwner {
        _open();
    }

    /**
     * @dev Closes the presale.
     */
    function close() external onlyOwner {
        _close();
    }
    
    /**
     * @dev Sets how many token units a buyer gets per wei
     * @param rate_ rate
     */
    function setRate(uint256 rate_) external onlyOwner {
        _rate = rate_;
        emit SetRate();
    }
    
    /**
     * @dev Sets a specific beneficiary's maximum contribution.
     */
    function setCap(uint256 cap_) external onlyOwner {
        _cap = cap_;
    }

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }

    /**
     * @return the amount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    /**
     * @return the amount of sold nfts.
     */
    function soldNfts() public view returns (uint256) {
        return _soldNfts;
    }

    /**
     * @return the cap of the presale.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Checks whether the cap has been reached.
     * @return Whether the cap was reached
     */
    function capReached() public view returns (bool) {
        return soldNfts() >= _cap;
    }

    /**
     * @return true if the presale has closed, false otherwise.
     */
    function isClosed() public view returns (bool) {
        return _closed;
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyNFT(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;

        require(weiAmount >= _rate, "Insufficient payment.");

        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        _sentzNFT.adminSpawn(beneficiary);

        // update state
        _weiRaised += weiAmount;

        // increment sold nfts count
        _soldNfts++;

        _forwardFunds();

        _postValidatePurchase();

        emit NFTPurchased(beneficiary);
    }

    /**
     * @dev Must be called when opening presale.
     */
    function _open() private {
        require(_closed, "Presale: already opened");

        _closed = false;

        emit PresaleOpened();
    }

    /**
     * @dev Must be called when closing presale.
     */
    function _close() private {
        require(!_closed, "Presale: already closed");

        _closed = true;

        emit PresaleClosed();
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from CryptoGodzPresale to extend their validations.
     * Example from CappedCryptoGodzPresale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) private view whenNotPaused whenOnlyOpened {
        require(beneficiary != address(0), "CryptoGodzPresale: beneficiary is the zero address");
        require(weiAmount != 0, "CryptoGodzPresale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     */
    function _postValidatePurchase() private {
        if (capReached()) {
            _pause();
        }
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() private {
        _wallet.transfer(msg.value);
    }
}