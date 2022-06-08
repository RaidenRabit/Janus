// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "./interfaces/ITokenFactory.sol";
import "./mocks/ERC20Mintable.sol";
import "./interfaces/IWhitelist.sol";

contract JanusAddOn {
    error ZeroAddress();

    // holds all addresses that are permited to interact with the add-on
    IWhitelist public whitelistHandler;
    // holds all the stakers (aka. Liquidity Providers)
    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    ERC20Mintable public proprietaryToken;
    address public owner;

    constructor(ERC20Mintable _proprietaryToken, IWhitelist _whitelistHandler) {
        proprietaryToken = _proprietaryToken;
        owner = msg.sender;
        whitelistHandler = _whitelistHandler;
    }

    function awardProprietaryTokenForStaking(uint _amount, address _staker, string memory _userWhitelist) public {
        if (!whitelistHandler.checkUser(_userWhitelist)) {
            revert('User not allowed');
        }
        require(_amount > 0, "amount cannot be 0");

        proprietaryToken.transfer(_staker, _amount);
        stakingBalance[_staker] = stakingBalance[_staker] + _amount;
        if(!hasStaked[_staker]) {
            stakers.push(_staker);
        }
        isStaking[_staker] = true;
        hasStaked[_staker] = true;
    }

    function getBalanceOfStaker(address _staker) public returns(uint) {
        return stakingBalance[_staker];
    }
}
