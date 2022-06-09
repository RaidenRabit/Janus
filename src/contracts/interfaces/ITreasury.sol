// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

interface ITreasury {
    function awardProprietaryTokenForStaking(
        address tokenAddress,
        uint amount,
        address user
    ) external returns(uint);

    function getBalanceOfStaker(address staker) external returns(uint);

    function getAwardRate() external returns(uint);

    function setAwardRate(uint newRate) external returns(uint);
}
