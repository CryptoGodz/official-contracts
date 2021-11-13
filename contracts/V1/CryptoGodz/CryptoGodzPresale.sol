// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../BEP20Pausable/IBEP20PausableUpgradeable.sol";
import "../BEP20Pausable/SafeBEP20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/escrow/EscrowUpgradeable.sol";

import "./DEADICryptoGodzPresaleVault.sol";

/**
 * @title CryptoGodz Presale
 */
contract CryptoGodzPresale is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
	constructor() initializer {}

	function initialize(
        uint256 rate_,
        address payable wallet_,
        uint256 cap_,
        IBEP20PausableUpgradeable cryptoGodzToken_,
        ICryptoGodzPresaleVault cryptoGodzPresaleVault_
    )
    public initializer {
		__Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();
        require(rate_ > 0, "CryptoGodzPresale: rate is 0");
        require(wallet_ != address(0), "CryptoGodzPresale: wallet is the zero address");
        require(address(cryptoGodzToken_) != address(0), "CryptoGodzPresale: token is the zero address");

        _rate = rate_;
        _wallet = wallet_;
        _cap = cap_;
        _closed = true;
        _withdrawalEnabled = false;

        _token = cryptoGodzToken_;
        _vault = cryptoGodzPresaleVault_;
	}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    using SafeMathUpgradeable for uint256;
    using SafeBEP20PausableUpgradeable for IBEP20PausableUpgradeable;

    // The token being sold
    IBEP20PausableUpgradeable private _token;

    // Address where funds are collected
    address payable private _wallet;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 private _rate;

    // Amount of wei raised
    uint256 private _weiRaised;
    
    // Token presale hard cap
    uint256 private _cap;
    
    mapping(address => uint256) private _contributions;
    mapping(address => uint256) private _caps;
    mapping(address => uint256) private _balances;
    
    bool private _closed;
    bool private _withdrawalEnabled;

    ICryptoGodzPresaleVault private _vault;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
    event WithdrawalEnabled();
    event WithdrawalDisabled();
    event PresaleOpened();
    event PresaleClosed();

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
     * @dev Reverts if withdrawal is enabled
     */
    modifier whenWithdrawalIsEnabled {
        require(withdrawalEnabled(), "Presale: withdrawal is not yet enabled.");
        _;
    }
    
    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
    receive() external payable {
        buyTokens(_msgSender());
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
     * @dev Enables withdrawal of sold tokens.
     */
    function enableWithdrawal() external onlyOwner {
        require(!_withdrawalEnabled, "Presale: withdrawal already enabled.");

        _withdrawalEnabled = true;

        emit WithdrawalEnabled();
    }

    /**
     * @dev Enables withdrawal of sold tokens.
     */
    function disableWithdrawal() external onlyOwner {
        require(_withdrawalEnabled, "Presale: withdrawal already disabled.");

        _withdrawalEnabled = false;

        emit WithdrawalDisabled();
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
     * @dev Sets a specific beneficiary's maximum contribution.
     * @param beneficiary_ Address to be capped
     * @param cap_ Wei limit for individual contribution
     */
    function setCap(address beneficiary_, uint256 cap_) external onlyOwner {
        _caps[beneficiary_] = cap_;
    }

    /**
     * @return the token being sold.
     */
    function token() public view returns (IBEP20PausableUpgradeable) {
        return _token;
    }

    /**
     * @return the address where funds are collected.
     */
    function wallet() public view returns (address payable) {
        return _wallet;
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
        return weiRaised() >= _cap;
    }

    /**
     * @dev Returns the cap of a specific beneficiary.
     * @param beneficiary Address whose cap is to be checked
     * @return Current cap for individual beneficiary
     */
    function getCap(address beneficiary) public view returns (uint256) {
        return _caps[beneficiary];
    }

    /**
     * @dev Returns the amount contributed so far by a specific beneficiary.
     * @param beneficiary Address of contributor
     * @return Beneficiary contribution so far
     */
    function getContribution(address beneficiary) public view returns (uint256) {
        return _contributions[beneficiary];
    }

    /**
     * @return true if the withdrawal is enabled, false otherwise.
     */
    function withdrawalEnabled() public view returns (bool) {
        return _withdrawalEnabled;
    }

    /**
     * @return true if the presale has closed, false otherwise.
     */
    function isClosed() public view returns (bool) {
        return _closed;
    }
    
    function balanceOf(address beneficiary_) public view returns (uint256) {
        return _balances[beneficiary_];
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase();
    }

    /**
     * @dev Withdraw tokens only after presale closes.
     * @param beneficiary Whose tokens will be withdrawn.
     */
    function withdrawTokens(address beneficiary) public whenOnlyClosed whenWithdrawalIsEnabled {
        // require(goalReached(), "Presale: goal not reached");

        uint256 amount = _balances[beneficiary];
        require(amount > 0, "Presale: beneficiary is not due any tokens");

        _balances[beneficiary] = 0;
        _vault.transfer(beneficiary, amount);
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
        require(weiRaised().add(weiAmount) <= _cap, "CryptoGodzPresale: cap exceeded");
        require(_contributions[beneficiary].add(weiAmount) <= _caps[beneficiary], "CryptoGodzPresale: beneficiary's cap exceeded");
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
     * @dev Source of tokens. Override this method to modify the way in which the presale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) private {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) private {
        _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);
        _deliverTokens(address(_vault), tokenAmount);
    }

    /**
     * @dev Override for extensions that require an private state to check for validity (current user contributions,
     * etc.)
     * @param beneficiary Address receiving the tokens
     * @param weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) private {
        _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) private view returns (uint256) {
        return weiAmount.mul(_rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() private {
        _wallet.transfer(msg.value);
    }
}