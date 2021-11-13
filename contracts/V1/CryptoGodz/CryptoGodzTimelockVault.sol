// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "../BEP20Pausable/IBEP20PausableUpgradeable.sol";
import "../BEP20Pausable/SafeBEP20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "./ICryptoGodzTimelockVault.sol";
import "../CryptoGodzStructs.sol";

/**
 * @dev A token holder contract that will allow a benificiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */

contract CryptoGodzTimelockVault is Initializable, UUPSUpgradeable, OwnableUpgradeable, AccessControlEnumerableUpgradeable, ICryptoGodzTimelockVault {
    using SafeMathUpgradeable for uint256;
    using SafeBEP20PausableUpgradeable for IBEP20PausableUpgradeable;

    /**
     * - mint game rewards through a minter role (RewardsManager, WalletTimelockManager)
     * - hold game rewards by transferring the rewards to WalletTimelockManager: _groupedTimelocks["gameRewards"][{address}] = CryptoGodzStructs.TimelockData
     * - claim game rewards through WalletTimelockManager:
     *   - require (tokenAmount > 0)
     *   - compute amount = releaseAmount.mul(tokenAmount)
     *   - require (amount > 0)
     *   - require (releaseTimeFrequency >= lastReleased.add(block.timestamp))
     *   - require (benificiary != address(0))
     *   - set lastReleased = block.timestamp; deduct tokenAmount = tokenAmount.sub(amount)
     *   - transfer from WalletTimelockManager to benificiary
     */
    mapping(bytes32 => uint256) private _timelockWhitelist;
    mapping(bytes32 => uint256) private _totalTokenHoldingsByGroup;
    mapping(bytes32 => mapping(address => CryptoGodzStructs.TimelockData)) private _groupedTimelocks;
    
    IBEP20PausableUpgradeable private _godzToken;

    /// @custom:oz-upgrades-unsafe-allow constructor
	constructor() initializer {}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

	function initialize(
        IBEP20PausableUpgradeable godzToken_
    ) public initializer {
		__ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
        __Context_init_unchained();
        __Ownable_init_unchained();

        _timelockWhitelist[keccak256(bytes(string("DEV")))] = 1;
        _timelockWhitelist[keccak256(bytes(string("SEED_INVESTORS")))] = 1;
        _timelockWhitelist[keccak256(bytes(string("PRESALE_INVESTORS")))] = 1;
        _timelockWhitelist[keccak256(bytes(string("AIRDROP")))] = 1;
        _timelockWhitelist[keccak256(bytes(string("GAME_REWARDS")))] = 1;

        _godzToken = godzToken_;
        
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
	}

    /**
     * @return the amount of timelocked tokens.
     */
    function getTotalTimeLockedTokens() public view returns (uint256) {
        return _godzToken.balanceOf(address(this));
    }

    /**
     * @return the amount of timelocked tokens per group.
     */
    function getDevTimeLockedTokens() public view returns (uint256) {
        return getTimeLockedTokensByGroup("DEV");
    }

    /**
     * @return the amount of timelocked tokens per group.
     */
    function getSeedInvestorsTimeLockedTokens() public view returns (uint256) {
        return getTimeLockedTokensByGroup("SEED_INVESTORS");
    }

    /**
     * @return the amount of timelocked tokens per group.
     */
    function getPresaleInvestorsTimeLockedTokens() public view returns (uint256) {
        return getTimeLockedTokensByGroup("PRESALE_INVESTORS");
    }
    
    /**
     * @return the amount of timelocked tokens per group.
     */
    function getAirdropTimeLockedTokens() public view returns (uint256) {
        return getTimeLockedTokensByGroup("AIRDROP");
    }
    
    /**
     * @return the amount of timelocked tokens per group.
     */
    function getRewardsTimeLockedTokens() public view returns (uint256) {
        return getTimeLockedTokensByGroup("GAME_REWARDS");
    }

    /**
     * @return the amount of timelocked tokens of single account from keccak256(bytes(string("DEV"))).
     */
    function getTimeLockedTokensByGroup(string memory group) public view returns (uint256) {
        bytes32 key = keccak256(bytes(group));
        return _totalTokenHoldingsByGroup[key];
    }

    /**
     * @return the amount of timelocked tokens of single account.
     */
    function getAccountTimeLockedTokens(string memory group, address account) public view returns (CryptoGodzStructs.TimelockData memory) {
        bytes32 key = keccak256(bytes(group));
        return _groupedTimelocks[key][account];
    }

    /**
     * Add a timelock rule
     * addTimelock(keccak256(bytes(string("DEV"))), {address}, [...uint256])
     */
    function addTimelock(
        string memory group,
        address benificiary,
        uint256 tokenAmount,
        uint256 lastReleased,
        uint256 releaseTimeFrequency,
        uint256 releaseAmount
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 key = keccak256(bytes(group));

        require(_timelockWhitelist[key] != uint256(0), "Timelock group not allowed.");
        
        if (_groupedTimelocks[key][benificiary].benificiary == address(0)) {
            _groupedTimelocks[key][benificiary] = CryptoGodzStructs.TimelockData({
                tokenAmount: tokenAmount,
                benificiary: benificiary,
                lastReleased: lastReleased,
                releaseTimeFrequency: releaseTimeFrequency,
                releaseAmount: releaseAmount
            });
        } else {
            _updateTimelock(
                key,
                benificiary,
                tokenAmount,
                lastReleased,
                releaseTimeFrequency,
                releaseAmount
            );
        }
        
        // store recet 
        _totalTokenHoldingsByGroup[key] = _totalTokenHoldingsByGroup[key].add(tokenAmount);
    }

    
    /**
     * Add a timelock rule
     * addTimelock(keccak256(bytes(string("DEV"))), {address}, [...uint256])
     */
    function _updateTimelock(
        bytes32 key,
        address benificiary,
        uint256 tokenAmount,
        uint256 lastReleased,
        uint256 releaseTimeFrequency,
        uint256 releaseAmount
    ) private {
        CryptoGodzStructs.TimelockData storage timelock = _groupedTimelocks[key][benificiary];

        // increase token amount instead
        if (timelock.tokenAmount != uint256(0)) {
            timelock.tokenAmount = timelock.tokenAmount.add(tokenAmount);
            timelock.releaseAmount = timelock.releaseAmount.add(releaseAmount);
        } else { // set token amount
            timelock.tokenAmount = tokenAmount;
            timelock.releaseAmount = releaseAmount;
            timelock.lastReleased = lastReleased;
            timelock.benificiary = benificiary;
            timelock.releaseTimeFrequency = releaseTimeFrequency;
        }
    }

    function claimTokens(string memory group, address benificiary) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 key = keccak256(bytes(group));

        CryptoGodzStructs.TimelockData storage timelockData = _groupedTimelocks[key][benificiary];

        require (benificiary != address(0), "Timelock tokens recipient must not be empty.");
        require(timelockData.tokenAmount > 0, "No timelocked tokens to claim.");
        require(timelockData.releaseAmount > 0, "No claimable tokens.");

        // check time if already past than the release time
        require(block.timestamp.sub(timelockData.lastReleased) >= (timelockData.releaseTimeFrequency * 1 days), "Tokens are still timelocked.");

        if (timelockData.tokenAmount < timelockData.releaseAmount) {
            timelockData.releaseAmount = timelockData.tokenAmount;
        }

        // timelocked token amount must be greater than claimable amount
        require(timelockData.tokenAmount >= timelockData.releaseAmount, "Unable to release tokens more than the allowed amount.");

        // re-set
        timelockData.lastReleased           = block.timestamp;
        timelockData.tokenAmount            = timelockData.tokenAmount.sub(timelockData.releaseAmount);
        _totalTokenHoldingsByGroup[key]   = _totalTokenHoldingsByGroup[key].sub(timelockData.releaseAmount);
        
        _godzToken.safeTransfer(benificiary, timelockData.releaseAmount);
    }
}
