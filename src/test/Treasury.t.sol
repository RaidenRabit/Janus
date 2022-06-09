// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "ds-test/test.sol";
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

contract TreasuryTest is DSTest {
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

    function setUp() public {
        token = new ERC20Mintable(tokenName, tokenSymbol);
        owner = address(this);
        Whitelist whitelist = new Whitelist();
        whitelist.whitelistUser(toAsciiString(address(this)));
        oracle = new Oracle(address(token), address(whitelist));
        treasury = new Treasury(address(token), address(oracle), address(whitelist));
    }

    function test_getBalanceOfStaker_fails_ZeroAddress() public {
        vm.expectRevert(encodeError("ZeroAddress()"));
        treasury.getBalanceOfStaker(address(0));
    }

    function test_getBalanceOfStaker_fails_NotStaking() public {
        vm.expectRevert(encodeError("NotStaking()"));
        treasury.getBalanceOfStaker(address(this));
    }

    function test_getBalanceOfStaker_fails_NoWhitelist() public {
        vm.expectRevert(encodeError("DataNotWhitelisted()"));
        vm.prank(addr1);
        treasury.getBalanceOfStaker(address(this));
    }

    function test_getBalanceOfStaker_success_0() public {
        uint amount = 10;
        ERC20Mintable t = new ERC20Mintable('Ethereum', 'ETH');
        treasury.awardProprietaryTokenForStaking(address(t), amount, address(this));

        uint result = treasury.getBalanceOfStaker(address(this));

        assertEq(result, 0);
    }

    function test_getBalanceOfStaker_whenNoAwardRateIsSet_success_equalToOracleConversion() public {
        uint amount = 10;
        ERC20Mintable t = new ERC20Mintable('Ethereum', 'ETH');
        treasury.awardProprietaryTokenForStaking(address(t), amount, address(this));
        uint awardRate = treasury.getAwardRate();
        uint conversionRate = oracle.convertToProprietaryToken(address(t), 1, address(this));

        uint result = treasury.getBalanceOfStaker(address(this));

        assertEq(result, 0);
        assertEq(awardRate, 0);
    }

    function test_getBalanceOfStaker_whenAwardRateIsSet_success_equalToOracleConversion() public {
        uint amount = 10;
        uint newAwardRate = 10; //10%
        ERC20Mintable t = new ERC20Mintable('Ethereum', 'ETH');
        treasury.setAwardRate(newAwardRate);
        treasury.awardProprietaryTokenForStaking(address(t), amount, address(this));
        uint awardRate = treasury.getAwardRate();
        uint conversionRate = oracle.convertToProprietaryToken(address(t), 1, address(this));

        uint result = treasury.getBalanceOfStaker(address(this));

        assertEq(result, mulScale(conversionRate * amount, awardRate, 100));
        assertEq(awardRate, newAwardRate);
    }

    function test_getAwardRate_whenNothingIsInitialized_success_0() public {
        assertEq(treasury.getAwardRate(), 0);
    }

    function test_setAwardRate_fail_onlyOwnerCanSetAwardRate() public {
        uint amount = 1000; //10%
        vm.expectRevert(encodeError("OnlyOwnerCanAccess()"));
        vm.prank(addr1);

        treasury.setAwardRate(amount);
    }

    function test_setAwardRate_success_initializedAmount() public {
        uint amount = 1000; //10%

        treasury.setAwardRate(amount);

        assertEq(treasury.getAwardRate(), amount);
    }
}
