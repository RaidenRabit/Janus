// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "./interfaces/ITokenFactory.sol";
import "./mocks/ERC20Mintable.sol";
import "./interfaces/IWhitelist.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IOptionsStruct.sol";

contract JanusAddOn is IOptionsStruct {
    error ZeroAddress();
    error CanNotBuyYourOwnOption();
    error NotEnoughBalance();

    // holds all addresses that are permited to interact with the add-on
    IWhitelist public whitelistHandler;
    ITreasury public treasuryHandler;
    IOracle public oracleHandler;
    ERC20Mintable public proprietaryToken;
    mapping (uint => Option) public options; // holds all options
    Option[] optionsArray;
    uint public optionCount;
    address public owner;

    constructor(address _proprietaryToken, address _whitelistHandler, address _treasuryHandler, address _oracleHandler) {
        optionCount = 0;
        proprietaryToken = ERC20Mintable(_proprietaryToken);
        owner = msg.sender;
        whitelistHandler = IWhitelist(_whitelistHandler);
        treasuryHandler = ITreasury(_treasuryHandler);
        oracleHandler = IOracle(_oracleHandler);
    }

    function createOption(string calldata _userWhitelist, address _tokenAddress, uint _amount, uint _strikePrice,
        uint _premiumValue, string calldata _duration, bool _isCall) public {
        if (!whitelistHandler.checkUser(_userWhitelist)) {
            revert('User not allowed');
        }
        ERC20Mintable mintableToken = ERC20Mintable(_tokenAddress);
        string memory tokenTitle = mintableToken.getName();
        string memory tokenSymbol = mintableToken.getSymbol();
        Token memory token = Token(_tokenAddress, tokenTitle, tokenSymbol);
        Option memory option = Option(optionCount, token, _amount, _strikePrice, _premiumValue, _duration, _isCall, address(0), msg.sender);
        options[optionCount] = option;
        optionsArray.push(option);
        optionCount++;
    }

    function buyOption(string calldata _userWhitelist, uint _optionID) public {
        if (!whitelistHandler.checkUser(_userWhitelist)) {
            revert('User not allowed');
        }
        if (msg.sender == options[_optionID].sellerAddress) {
            revert CanNotBuyYourOwnOption();
        }
        uint buyerBalance = treasuryHandler.getBalanceOfStaker(msg.sender);
        Option memory option = options[_optionID];
        uint optionValueInProprietaryTokens = oracleHandler.convertToProprietaryToken(option.token.tokenAddress, option.amount, msg.sender);
        int subTotal = int(buyerBalance) - int(optionValueInProprietaryTokens);
        if (subTotal < 0) {
            revert NotEnoughBalance();
        }
        option.buyerAddress = msg.sender;
        options[_optionID] = option;
        optionsArray[_optionID] = option;
    }

    function buyOption1(uint _optionID) public {
        if (msg.sender == options[_optionID].sellerAddress) {
            revert CanNotBuyYourOwnOption();
        }
        uint buyerBalance = treasuryHandler.getBalanceOfStaker(msg.sender);
        Option memory option = options[_optionID];
        uint optionValueInProprietaryTokens = oracleHandler.convertToProprietaryToken(option.token.tokenAddress, option.amount, msg.sender);
        int subTotal = int(buyerBalance) - int(optionValueInProprietaryTokens);
        if (subTotal < 0) {
            revert NotEnoughBalance();
        }
        option.buyerAddress = msg.sender;
        options[_optionID] = option;
        optionsArray[_optionID] = option;
    }

    function getOptionByID(uint _optionID) public view returns(Option memory) {
        return options[_optionID];
    }

    function getOptionsCount() public view returns(uint) {
        return optionCount;
    }

    function getAllOptions() public view returns(Option[] memory) {
        return optionsArray;
    }

    function executeOption(string calldata _userWhitelist, uint _optionID) public {
        Option memory option = options[_optionID];
        uint amount = oracleHandler.convertToProprietaryToken(option.token.tokenAddress, option.amount, msg.sender);
        treasuryHandler.reduceBalanceOfStaker(option.sellerAddress, amount);
        treasuryHandler.awardProprietaryTokenForStaking(option.sellerAddress, amount, option.buyerAddress);
    }
}
