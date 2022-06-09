// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "./mocks/ERC20Mintable.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IWhitelist.sol";
import "./Whitelist.sol";

contract Oracle is IOracle {
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
    function mulScale (uint x, uint y, uint128 scale)
    internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    error ZeroAddress();
    error ZeroAmount();
    error OnlyOwnerCanAccess();

    mapping(address => uint) public valueToProprietaryToken;
    mapping(address => bool) public checkedToken;
    ERC20Mintable public proprietaryToken;
    IWhitelist public whitelist;
    address public owner;

    constructor(address _proprietaryTokenAddress, address _whitelistAddress) {
        proprietaryToken = ERC20Mintable(_proprietaryTokenAddress);
        whitelist = IWhitelist(_whitelistAddress);
        owner = msg.sender;
    }

    function random() internal view returns (uint) {
        uint randomnumber = uint(blockhash(block.number-1)) % 100;
        randomnumber = randomnumber + 1;
        return randomnumber;
    }


    function setConversionRate(address _tokenAddress, uint _conversionRateToOneProprietaryToken) external returns (uint){
        if (msg.sender != owner) {
            revert OnlyOwnerCanAccess();
        }

        if (_tokenAddress == address(0)) {
            revert ZeroAddress();
        }
        if (_conversionRateToOneProprietaryToken == 0) {
            revert ZeroAmount();
        }
        valueToProprietaryToken[_tokenAddress] = _conversionRateToOneProprietaryToken;
        checkedToken[_tokenAddress] = true;
        return _conversionRateToOneProprietaryToken;
    }

    function convertToProprietaryToken(
        address _tokenAddress,
        uint _amount,
        address _user
    ) public returns (uint){
        whitelist.checkUser(toAsciiString(_user));
        if (_tokenAddress == address(0)) {
            revert ZeroAddress();
        }
        if (_amount == 0) {
            revert ZeroAmount();
        }

        if (checkedToken[_tokenAddress]) {
            return mulScale(valueToProprietaryToken[_tokenAddress], _amount, 100);
        } else {
            uint outsideConversionRate = random();
            checkedToken[_tokenAddress] = true;
            valueToProprietaryToken[_tokenAddress] = outsideConversionRate;
            return mulScale(outsideConversionRate, _amount, 100);
        }
    }
}
