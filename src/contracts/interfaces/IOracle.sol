// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

interface IOracle {
    function convertToProprietaryToken(
        address tokenAddress,
        uint amount,
        address user
    ) external returns (uint);

    function setConversionRate(address tokenAddress, uint conversionRateToOneProprietaryToken) external returns (uint);
}
