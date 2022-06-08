// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "ds-test/test.sol";
import "../contracts/mocks/ERC20Mintable.sol";
import "../contracts/TokenFactory.sol";

interface Vm {
    function expectRevert(bytes calldata) external;
}

contract TokenFactoryTest is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    TokenFactory factory;

    function setUp() public {
        factory = new TokenFactory();
    }

    function encodeError(string memory error)
        internal
        pure
        returns (bytes memory encoded)
    {
        encoded = abi.encodeWithSignature(error);
    }

    function getAllTokens_NothingDeployed() public {
        address[] memory result = factory.getAllTokens();
        assertEq(result.length, 0);
    }

    function addToken_getAllTokenCountIsOne() public {
        ERC20Mintable token0 = new ERC20Mintable('Name', 'Symbol');
        factory.addToken(address(token0));

        address[] memory result = factory.getAllTokens();
        assertEq(result.length, 1);
    }

    function deployToken_getAllTokenCountIsOne() public {
        factory.deployToken('Name', 'Symbol', 100);

        address[] memory result = factory.getAllTokens();
        assertEq(result.length, 1);
    }
}
