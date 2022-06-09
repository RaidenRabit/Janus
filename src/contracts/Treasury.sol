// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "./interfaces/IWhitelist.sol";
import "./mocks/ERC20Mintable.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/ITreasury.sol";
import "./Oracle.sol";
import "./Whitelist.sol";

contract Treasury is ITreasury {
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

    error OnlyOwnerCanAccess();
    error ZeroAddress();
    error ZeroAmount();
    error NotStaking();

    // holds all the stakers (aka. Liquidity Providers)
    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    ERC20Mintable public proprietaryToken;
    IOracle public oracle;
    IWhitelist public whitelist;
    address public owner;
    uint awardRate;

    constructor(address _proprietaryTokenAddress, address _oracleAddress, address _whitelistAddress) {
        proprietaryToken = ERC20Mintable(_proprietaryTokenAddress);
        oracle = Oracle(_oracleAddress);
        whitelist = Whitelist(_whitelistAddress);
        owner = msg.sender;
        awardRate = 0; // 0%
    }

    function getAwardRate() public view returns(uint) {
        return awardRate;
    }

    function setAwardRate(uint newRate) public returns(uint) {
        if (msg.sender != owner) {
            revert OnlyOwnerCanAccess();
        }
        awardRate = newRate;
        return newRate;
    }

    function awardProprietaryTokenForStaking(
        address _tokenAddress,
        uint _amount,
        address _user
    ) public returns(uint) {
        whitelist.checkUser(toAsciiString(_user));
        if(_amount <= 0) {
            revert ZeroAmount();
        }

        uint amount = mulScale(oracle.convertToProprietaryToken(_tokenAddress, _amount, _user), awardRate, 100);

        proprietaryToken.mint(amount, _user);
        stakingBalance[_user] = stakingBalance[_user] + amount;
        if(!hasStaked[_user]) {
            stakers.push(payable(_user));
        }
        isStaking[_user] = true;
        hasStaked[_user] = true;
        return stakingBalance[_user];
    }

    function getBalanceOfStaker(address _staker) public returns(uint) {
        whitelist.checkUser(toAsciiString(msg.sender));
        if (_staker == address(0)) {
            revert ZeroAddress();
        }
        if (!hasStaked[_staker]) {
            revert NotStaking();
        }
        return stakingBalance[_staker];
    }
}
