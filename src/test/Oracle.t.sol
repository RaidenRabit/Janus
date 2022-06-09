// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "ds-test/test.sol";
import "../contracts/Oracle.sol";
import "../contracts/Whitelist.sol";

interface Vm {
    function expectRevert(bytes calldata) external;
    function prank(address) external;
}

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract OracleTest is DSTest {

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


    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address public owner;
    address public addr1;
    Oracle oracle;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    ERC20Mintable token;
    string tokenName = 'TokenName';
    string tokenSymbol = 'Symbol';

    function setUp() public {
        token = new ERC20Mintable(tokenName, tokenSymbol);
        owner = address(this);
        Whitelist whitelist = new Whitelist();
        whitelist.whitelistUser(toAsciiString(address(this)));
        oracle = new Oracle(address(token), address(whitelist));
    }

    function test_convertToProprietaryToken_fails_ZeroAddress() public {
        vm.expectRevert(encodeError("ZeroAddress()"));
        oracle.convertToProprietaryToken(address(0), 1, address(this));
    }
    function test_convertToProprietaryToken_fails_ZeroAmount() public {
        vm.expectRevert(encodeError("ZeroAmount()"));
        oracle.convertToProprietaryToken(address(token), 0, address(this));
    }
    function test_convertToProprietaryToken_fails_NoWhitelist() public {
        vm.expectRevert(encodeError("DataNotWhitelisted()"));
        vm.prank(addr1);
        oracle.convertToProprietaryToken(address(token), 10, address(addr1));
    }
    function test_convertToProprietaryToken_success_newRandomValue() public {
        uint result = oracle.convertToProprietaryToken(address(token), 100, address(this));
        assertGt(result, 0);
    }


    function test_setConversionRate_fails_ZeroAddress() public {
        vm.expectRevert(encodeError("ZeroAddress()"));
        oracle.setConversionRate(address(0), 1);
    }
    function test_setConversionRate_fails_ZeroAmount() public {
        vm.expectRevert(encodeError("ZeroAmount()"));
        oracle.setConversionRate(address(token), 0);
    }
    function test_setConversionRate_fail_onlyOwnerCanAccess() public {
        vm.expectRevert(encodeError("OnlyOwnerCanAccess()"));
        vm.prank(addr1);
        oracle.setConversionRate(address(token), 10);
    }
    function test_setConversionRate_updateTokenRate_success_correctConversionRate() public {
        uint amount = 1000; // 10% as in: 1 token = 0.1 proprietary tokens

        oracle.setConversionRate(address(token), amount);

        uint conversionRate = oracle.convertToProprietaryToken(address(token), 1, address(this));
        assertEq(conversionRate, 10);
    }
    function test_setConversionRate_newTokenRate_success_correctConversionRate() public {
        uint amount = 100; // 1% as in: 1 ETH = 0.01 proprietary tokens
        ERC20Mintable t = new ERC20Mintable('Ethereum', 'ETH');

        oracle.setConversionRate(address(t), amount);

        uint conversionRate = oracle.convertToProprietaryToken(address(t), 1, address(this));
        assertEq(conversionRate, 1);
    }
    function test_setConversionRate_1000percentConversionRate_success_correctConversionRate() public {
        uint amount = 100000; // 1 000% as in: 1 ETH = 0.01 proprietary tokens
        ERC20Mintable t = new ERC20Mintable('Ethereum', 'ETH');

        oracle.setConversionRate(address(t), amount);

        uint conversionRate = oracle.convertToProprietaryToken(address(t), 1, address(this));
        assertEq(conversionRate, 1000);
    }
}
