// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "./interfaces/IWhitelist.sol";

contract Whitelist is IWhitelist {
    error EmptyDataProvided();
    error DataNotWhitelisted();
    error OnlyOwnerCanWhitelist();

    // holds all addresses that are permited to interact with the add-on
    mapping(string => bool) public whitelistedAddresses;
    uint whitelistSize;
    address public owner;

    constructor() {
        whitelistSize = 0;
        owner = msg.sender;
    }

    function countWhitelist() public view returns(uint) {
        return whitelistSize;
    }

    function checkUser(string memory _data) public view returns(bool) {
        bytes memory tempEmptyStringTest = bytes(_data);
        if (tempEmptyStringTest.length == 0) {
            revert EmptyDataProvided();
        }
        if(!whitelistedAddresses[_data]) {
            revert DataNotWhitelisted();
        }
        return true;
    }

    function whitelistUser(string memory _data) public {
        if (msg.sender != owner) {
            revert OnlyOwnerCanWhitelist();
        }
        if(!whitelistedAddresses[_data]) {
            whitelistedAddresses[_data] = true;
            whitelistSize = whitelistSize + 1;
        }
    }
}
