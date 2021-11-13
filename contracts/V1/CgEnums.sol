// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library CgEnums {
    enum BonusType {
        SKILL, 
        ITEM
    }

    enum BonusAttribute {
        WILL_POWER, // (+1 - +50)
        WINRATE, 
        REWARDS, // 1000%
        TRANSMUTE_CHANCE
    }

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

    enum ArmyBuffClass {
        MASTER, // 150% increase on Buff's Attribute
        GODLY // 200% increase on Buff's Attribute
    }

    enum ArmyBuffAttribute {
        WILL_POWER,
        REWARDS
    }

    enum SubNftUsageType {
        LIMITED,
        UNLIMITED
    }
}