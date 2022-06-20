// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "ds-test/test.sol";
import "../contracts/mocks/ERC20Mintable.sol";
import "../contracts/TokenFactory.sol";
import "../contracts/Oracle.sol";
import "../contracts/Whitelist.sol";
import "../contracts/Treasury.sol";

interface Vm {
    function expectRevert(bytes calldata) external;
    function prank(address) external;
}

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract TokenFactoryTest is DSTest {
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
    function encodeError(string memory error)
    internal
    pure
    returns (bytes memory encoded)
    {
        encoded = abi.encodeWithSignature(error);
    }
    function mulScale (uint x, uint y, uint128 scale)
    internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address public owner;
    address public addr1;
    Oracle oracle;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    ERC20Mintable token;
    string tokenName = 'TokenName';
    string tokenSymbol = 'Symbol';
    Treasury treasury;
    TokenFactory factory;

    function setUp() public {
        token = new ERC20Mintable(tokenName, tokenSymbol);
        token.mint(10000, address(this));
        owner = address(this);
        Whitelist whitelist = new Whitelist();
        whitelist.whitelistUser(toAsciiString(address(this)));
        oracle = new Oracle(address(token), address(whitelist));
        treasury = new Treasury(address(token), address(oracle), address(whitelist));
        factory = new TokenFactory(address(whitelist), address(treasury), address(token), address(oracle));
    }

    function test_getAllTokens_NothingDeployed() public {
        address[] memory result = factory.getAllTokens();
        assertEq(result.length, 0);
    }

    function test_addToken_getAllTokenCountIsOne() public {
        ERC20Mintable token0 = new ERC20Mintable('Name', 'Symbol');
        factory.addToken(address(token0));

        address[] memory result = factory.getAllTokens();
        assertEq(result.length, 1);
    }

    function test_stakeToken_getAllTokenCountIsOne() public {
        factory.stakeToken('Name', 'Symbol', 100);

        address[] memory result = factory.getAllTokens();
        assertEq(result.length, 1);
    }

    function test_stakeToken_deployedTokenIsMintedWithTheRequestedAmount() public {
        uint amount = 100;
        factory.stakeToken('Name', 'Symbol', amount);

        address[] memory result = factory.getAllTokens();
        ERC20Mintable t = ERC20Mintable(result[0]);

        assertEq(t.balanceOf(address(this)), amount);
    }

    function test_stakeToken_whenNoRewardRateIsSet_0awardedProprietary() public {
        uint amount = 100;

        factory.stakeToken('Name', 'Symbol', amount);

        assertEq(treasury.getBalanceOfStaker(address(this)), 0);
    }

    function test_stakeToken_whenRewardRateIsSet_someAwardedProprietaryToken() public {
        uint amount = 100;
        treasury.setAwardRate(5); //2% award rate

        factory.stakeToken('Name', 'Symbol', amount);

        assertGt(treasury.getBalanceOfStaker(address(this)), 0);
    }

    function test_setTotalAmountOfToken_newValue() public {
        uint amount = 100;

        factory.setTotalAmountOfToken(address(token), amount);

        assertEq(factory.getTotalAmountOfToken(address(token)), amount);
    }
}
