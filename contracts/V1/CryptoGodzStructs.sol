// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;


library CryptoGodzStructs {
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    enum Element {
        EARTH,
        WATER,
        FIRE,
        WIND
    }

    enum Class {
        BASIC,
        CRYSTAL,
        SHADOW,
        HOLY
    }
 

    struct TimelockData {
        uint256 tokenAmount; // amount of tokens under timelocked
        address benificiary; // recipient timelocked address
        uint256 lastReleased; // date in seconds when the timelock was last released
        uint256 releaseTimeFrequency; // value of time to complete before releasing the timelock since lastReleased
        uint256 releaseAmount; // release percentage of the tokenAmount
    }


    struct CryptoSentz {
        Element element;
        Class class;
        uint256 level;
        uint256 spirit;
        bool transmuted;
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
        Element enemyElement;
        Class enemyClass;
    }

}