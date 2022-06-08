// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./ERC20.sol"; //solmate copy

contract ERC20Mintable is ERC20 {

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_, 18)
    {}

    function getName() public view returns (string memory) {
        return name;
    }

    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    function mint(uint256 amount, address to) public {
        _mint(to, amount);
    }
}
