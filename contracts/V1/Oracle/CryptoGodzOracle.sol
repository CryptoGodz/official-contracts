// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./FixedPoint.sol";
import './IPancakePair.sol';
import "./PancakeLibrary.sol";
import "./PancakeOracleLibrary.sol";
import "./ICryptoGodzOracle.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// fixed window oracle that recomputes the average price for the entire period once every period
// note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
contract CryptoGodzOracle is Initializable, OwnableUpgradeable, UUPSUpgradeable, ICryptoGodzOracle {
    using FixedPoint for *;

    IPancakePair public pair;
    address public token0;
    address public token1;

    uint256    public price0CumulativeLast;
    uint256    public price1CumulativeLast;
    uint32  public blockTimestampLast;
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    /// @custom:oz-upgrades-unsafe-allow constructor
	constructor() initializer {}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

	function initialize(
        IPancakePair pair_
    ) public initializer {
		__CryptoGodz_init(pair_);
	}

	function __CryptoGodz_init(
        IPancakePair pair_
    ) public initializer {
		__Ownable_init_unchained();
		__CryptoGodz_init_unchained(pair_);
	}

	function __CryptoGodz_init_unchained(
        IPancakePair pair_
    ) public initializer {
        pair = pair_;
        token0 = pair_.token0();
        token1 = pair_.token1();
        price0CumulativeLast = pair_.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = pair_.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = pair_.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'CryptoGodzOracle: NO_RESERVES'); // ensure that there's liquidity in the pair
	}

    function update() external override {
        (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        ) = PancakeOracleLibrary.currentCumulativePrices(address(pair));

        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed));
        price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed));

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(address token, uint256 amountIn) external view returns (uint256 amountOut) {
        if (token == token0) {
            amountOut = price0Average.mul(amountIn).decode144();
        } else {
            require(token == token1, 'CryptoGodzOracle: INVALID_TOKEN');
            amountOut = price1Average.mul(amountIn).decode144();
        }
    }
}