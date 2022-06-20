// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

interface ITokenFactory {

    function getAllTokens() external returns(address[] memory);

    function stakeToken(string memory, string memory, uint) external returns(address);
}
