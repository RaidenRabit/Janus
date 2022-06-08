// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "ds-test/test.sol";
import "../contracts/mocks/ERC20Mintable.sol";

interface Vm {
    function expectRevert(bytes calldata) external;
}

contract ERC20MintableTest is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    ERC20Mintable token;
    string tokenName = 'TokenName';
    string tokenSymbol = 'Symbol';

    function setUp() public {
        token = new ERC20Mintable(tokenName, tokenSymbol);
    }

    function testItDeploys_WithCorrectNames() public {
        string memory name = 'Name';
        string memory symbol = 'Symbol';
        ERC20Mintable token0 = new ERC20Mintable(name, symbol);

        assertEq(token0.getName(), name);
        assertEq(token0.getSymbol(), symbol);
    }

    function testItDeploys_NoAmountOfTokens() public {
        assertEq(token.balanceOf(msg.sender), 0);
    }

    function testItMints_100Tokens() public {
        token.mint(100, msg.sender);
        assertEq(token.balanceOf(msg.sender), 100);
    }

    function testItMintsMultipleTimes_1000TokensTotal() public {
        token.mint(100, msg.sender);
        token.mint(200, msg.sender);
        token.mint(700, msg.sender);
        assertEq(token.balanceOf(msg.sender), 1000);
    }
}
