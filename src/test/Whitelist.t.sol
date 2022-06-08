// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "ds-test/test.sol";
import "../contracts/Whitelist.sol";

interface Vm {
    function expectRevert(bytes calldata) external;
    function prank(address) external;
}

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract WhitelistTest is DSTest {

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
    Whitelist whitelist;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        owner = address(this);
        whitelist = new Whitelist();
    }

    function testItDeploys_AddressIsNot0() public {
        bool contractAddressIs0Address = address(whitelist) == address(0);
        assertTrue(!contractAddressIs0Address);
    }

    function testItDeploys_NoWhitelistedAddresses() public {
        assertEq(whitelist.countWhitelist(), 0);
    }

    function testItWhitelists_NewCountIs1() public {
        whitelist.whitelistUser(toAsciiString(address(this)));

        assertEq(whitelist.countWhitelist(), 1);
    }

    function testCheckUserWhenNoDataIsProvided_FailsWithEmptyWhitelistArray() public {
        vm.expectRevert(encodeError("EmptyDataProvided()"));

        whitelist.checkUser('');
    }

    function testCheckUserWhenNoWhitelistingIsDone_FailsWithEmptyWhitelistArray() public {
        vm.expectRevert(encodeError("DataNotWhitelisted()"));

        whitelist.checkUser(toAsciiString(address(this)));
    }

    function testCheckUserWithOneWhitelist_True() public {
        whitelist.whitelistUser(toAsciiString(address(this)));

        bool isWhitelisted = whitelist.checkUser(toAsciiString(address(this)));
        assertTrue(isWhitelisted);
    }

    function testWhitelistUser_FailOnlyOwnerCanWhitelist() public {
        vm.expectRevert(encodeError("OnlyOwnerCanWhitelist()"));
        vm.prank(addr1);
        whitelist.whitelistUser(toAsciiString(address(this)));
    }
}
