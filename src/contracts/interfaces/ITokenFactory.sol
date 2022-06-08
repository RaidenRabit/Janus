// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

interface ITokenFactory {

    function getAllTokens() external returns(address[] memory);

    function deployToken(string memory, string memory, uint256) external;
}
