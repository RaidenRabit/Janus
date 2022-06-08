// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

interface IWhitelist {
    function checkUser(string calldata) external returns(bool);

    function whitelistUser(string calldata) external;
}
