// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;


import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

library CryptoGodzStructsV2 {
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    enum TreasureChestType {
        ANCIENT,
        CRYSTAL,
        SHADOW,
        HOLY
    }

    enum SentzClass {
        BASIC,
        CRYSTAL,
        SHADOW,
        HOLY
    }

    enum SentzElement {
        EARTH,
        WATER,
        FIRE,
        WIND
    }

    enum BonusAttribute {
        WILL_POWER, // (+1 - +50)
        WIN_CHANCE, 
        REWARDS, // 1000%
        TRANSMUTE_CHANCE
    }

    enum ArmyBuffClass {
        MASTER, // +50% increase on Buff's Attribute
        GODLY // +100% increase on Buff's Attribute
    }

    enum ArmyBuffAttribute {
        WILL_POWER,
        REWARDS
    }

    enum SubNftUsageType {
        LIMITED,
        UNLIMITED
    }

    struct Sentz {
        SentzClass class;
        SentzElement element;
        uint256 rarity;
        uint256 willPower;
        uint256 level;
        uint256 spirit;
        uint256 armyId;
        bool isTransmuted;
        EnumerableSetUpgradeable.UintSet skills; // [uint256(SentzSkill), ...]
        EnumerableSetUpgradeable.UintSet items; // [uint256(SentzItem), ...]
        mapping(BonusAttribute => uint256) bonusAttribute;
        mapping(BonusAttribute => uint256) negativeBonusAttribute;
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
        ArmyBuffAttribute buff;
        uint256 buffValue;
    }

    struct ArmyBuff {
        ArmyBuffClass class;
        ArmyBuffAttribute Attribute;
    }

    struct SentzSkill {
        SentzElement element; // sentz compatibility
        SubNftUsageType usageType;
        uint256 usageCount;
        BonusAttribute positive;
        BonusAttribute negative;
        uint256 positiveValue;
        uint256 negativeValue;
        uint256 sentzId;
    }

    struct SentzItem {
        SentzElement element; // sentz compatibility
        SubNftUsageType usageType; // 0 = Limited | 1 = Unlimited
        uint256 usageCount;
        BonusAttribute positive;
        BonusAttribute negative; // less -10% win chance
        uint256 positiveValue;
        uint256 negativeValue;
        uint256 sentzId;
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

    struct FightHistory {
        address player;
        uint256 tokenId;
        uint256 rewards;
        uint256 date;
        uint256 winrate;
        bool hasWon;
        bool isMinted;
        SentzElement enemyElement;
        SentzClass enemyClass;
    }

}