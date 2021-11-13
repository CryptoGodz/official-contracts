// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./CgEnums.sol";


library CgStructs {
    struct SentzRarity {
        uint256 awakening;
        uint256 willPowerRangeStart;
        uint256 willPowerRangeEnd;
    }

    struct Sentz {
        CgEnums.SentzClass class;
        CgEnums.SentzElement element;
        uint256 rarity;
        uint256 willPower;
        uint256 level;
        uint256 spirit;
        uint256 armyId;
        address transmuter;
        bool isTransmuted;
    }

    struct SentzSkill {
        CgEnums.SentzElement element; // sentz compatibility
        CgEnums.SubNftUsageType usageType;
        uint256 usageCount;
        CgEnums.BonusAttribute positive;
        CgEnums.BonusAttribute negative;
        uint256 positiveValue;
        uint256 negativeValue;
        uint256 sentzId;
    }

    struct SentzItem {
        CgEnums.SentzElement element; // sentz compatibility
        CgEnums.SubNftUsageType usageType; // 0 = Limited | 1 = Unlimited
        uint256 usageCount;
        CgEnums.BonusAttribute positive;
        CgEnums.BonusAttribute negative; // less -10% win chance
        uint256 positiveValue;
        uint256 negativeValue;
        uint256 sentzId;
    }

    struct SentzLegion {
        uint256 rarity;
        uint256 sentzCapacity;
        uint256 armyId;
    }

    struct SentzArmy {
        EnumerableSetUpgradeable.UintSet sentz; // [uint256(sentzId), ...]
        EnumerableSetUpgradeable.UintSet sentzLegion; // [uint256(sentzLegionId), ...]
        uint256 willPower;
        CgEnums.ArmyBuffAttribute buff;
        uint256 buffValue;
    }

    struct ArmyBuff {
        CgEnums.ArmyBuffClass class;
        CgEnums.ArmyBuffAttribute Attribute;
        uint256 armyId;
    }

    struct TimelockData {
        uint256 tokenAmount; // amount of tokens under timelocked
        address benificiary; // recipient timelocked address
        uint256 lastReleased; // date in seconds when the timelock was last released
        uint256 releaseTimeFrequency; // value of time to complete before releasing the timelock since lastReleased
        uint256 releaseAmount; // release percentage of the tokenAmount
    }

    struct ItemSale {
        uint256 tokenId;
        address owner;
        uint256 price;
    }

    struct CombatHistory {
        address player;
        uint256 armyId;
        uint256 willPower;
        uint256 rewards;
        uint256 winrate;
        uint256 umbraLevel;
        uint256 damageRequired;
        uint256 damageDealt;
        bool hasWon;
        uint256 date;
    }
}