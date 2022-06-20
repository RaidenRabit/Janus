// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "ds-test/test.sol";
import "../contracts/mocks/ERC20Mintable.sol";
import "../contracts/TokenFactory.sol";
import "../contracts/Oracle.sol";
import "../contracts/Whitelist.sol";
import "../contracts/Treasury.sol";
import "../contracts/JanusAddOn.sol";
import "../contracts/ZuniswapV2Factory.sol";
import "../contracts/ZuniswapV2Pair.sol";
import "../contracts/interfaces/IOptionsStruct.sol";

interface Vm {
    function expectRevert(bytes calldata) external;
    function prank(address) external;
}

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract JanusAddOnTest is DSTest, IOptionsStruct {
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
    address public addr2;
    Oracle oracle;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    ERC20Mintable token;
    ERC20Mintable optionsToken;
    string tokenName = 'TokenName';
    string tokenSymbol = 'Symbol';
    string optionTokenName = 'Ethereum';
    string optionTokenSymbol = 'ETH';
    Treasury treasury;
    TokenFactory factory;
    JanusAddOn addOn;
    ZuniswapV2Factory uniswapFactory;

    function setUp() public {
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);
        token = new ERC20Mintable(tokenName, tokenSymbol);
        token.mint(10000, address(this));

        owner = address(this);
        Whitelist whitelist = new Whitelist();
        whitelist.whitelistUser(toAsciiString(address(this)));
        whitelist.whitelistUser(toAsciiString(addr1));
        whitelist.whitelistUser(toAsciiString(addr2));
        oracle = new Oracle(address(token), address(whitelist));
        treasury = new Treasury(address(token), address(oracle), address(whitelist));
        factory = new TokenFactory(address(whitelist), address(treasury), address(token), address(oracle));
        treasury.setAwardRate(100); //100% award rate
        addOn = new JanusAddOn(address(token), address(whitelist), address(treasury), address(oracle));

        address optionsTokenAddress = factory.stakeToken(optionTokenName, optionTokenSymbol, 100);
        optionsToken = ERC20Mintable(optionsTokenAddress);

        vm.prank(addr1);
        factory.stakeToken(optionTokenName, optionTokenSymbol, 1);
        vm.prank(addr2);
        factory.stakeToken(optionTokenName, optionTokenSymbol, 100);
    }

    function test_getOptionsCount_whenNonInitialized() public {
        assertEq(addOn.getOptionsCount(), 0);
    }

    function test_createOption_newCountIs_1_and_can_get_the_option() public {
        uint amount = 10;
        uint strikePrice = 1;
        uint premiumValue = 2;
        string memory duration = '1 Day';
        bool isCall = true;
        addOn.createOption(toAsciiString(address(this)), address(optionsToken), amount, strikePrice, premiumValue, duration, isCall);

        Option memory option = addOn.getOptionByID(0);
        assertEq(addOn.getOptionsCount(), 1);
        assertEq(option.amount, amount);
        assertEq(option.strikePrice, strikePrice);
        assertEq(option.premiumValue, premiumValue);
        assertEq(option.duration, duration);
    }

    function test_buyOption_CanNotBuyYourOwnOption() public {
        uint amount = 10;
        uint strikePrice = 1;
        uint premiumValue = 2;
        string memory duration = '1 Day';
        bool isCall = true;
        addOn.createOption(toAsciiString(address(this)), address(optionsToken), amount, strikePrice, premiumValue, duration, isCall);
        vm.expectRevert(encodeError("CanNotBuyYourOwnOption()"));

        addOn.buyOption(toAsciiString(address(this)), 0);
    }

    function test_buyOption_notEnoughBalanceToBuy() public {
        uint amount = 10;
        uint strikePrice = 1;
        uint premiumValue = 2;
        string memory duration = '1 Day';
        bool isCall = true;
        addOn.createOption(toAsciiString(address(this)), address(optionsToken), amount, strikePrice, premiumValue, duration, isCall);
        vm.expectRevert(encodeError("NotEnoughBalance()"));

        vm.prank(addr1);
        addOn.buyOption(toAsciiString(addr1), 1);
    }

    function test_buyOption_buyerAddressIsCorrect() public {
        uint amount = 10;
        uint strikePrice = 1;
        uint premiumValue = 2;
        string memory duration = '1 Day';
        bool isCall = true;
        addOn.createOption(toAsciiString(address(this)), address(optionsToken), amount, strikePrice, premiumValue, duration, isCall);

        vm.prank(addr2);
        addOn.buyOption(toAsciiString(addr2), 0);

        Option memory option = addOn.getOptionByID(0);
        assertEq(option.buyerAddress, addr2);
    }

    function test_getAllOptions_NoOptionsInTheBegining() public {
        assertEq(addOn.getAllOptions().length, 0);
    }

    function test_getAllOptions_1option() public {
        uint amount = 10;
        uint strikePrice = 1;
        uint premiumValue = 2;
        string memory duration = '1 Day';
        bool isCall = true;
        addOn.createOption(toAsciiString(address(this)), address(optionsToken), amount, strikePrice, premiumValue, duration, isCall);

        assertEq(addOn.getAllOptions().length, 1);
    }
}
