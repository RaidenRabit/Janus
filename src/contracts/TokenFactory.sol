// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "./mocks/ERC20Mintable.sol";
import "./JanusAddOn.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IWhitelist.sol";

contract TokenFactory {

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



    IWhitelist public whitelist;
    ITreasury public treasury;
    IOracle public oracle;
    ERC20Mintable public proprietaryToken;
    address[] deployedTokenAddresses;
    mapping(address => bool) public deployedTokenAddressesCheck;
    mapping(string => address) public deployedTokenSymbolsToAddress;
    mapping(string => bool) public deployedTokenSymbolStrings;

    constructor(address _whitelistAddress, address _treasuryAddress, address _proprietaryTokenAddress, address _oracleAddress) {
        whitelist = IWhitelist(_whitelistAddress);
        proprietaryToken = ERC20Mintable(_proprietaryTokenAddress);
        oracle = IOracle(_oracleAddress);
        treasury = ITreasury(_treasuryAddress);
    }

    function getAllTokens() public view returns(address[] memory) {
        return deployedTokenAddresses;
    }

    function addToken(address _token) public {
        if(!deployedTokenAddressesCheck[_token]) {
            deployedTokenAddresses.push(_token);
            deployedTokenAddressesCheck[_token] = true;
        }
    }

    event TokenDeployed(address tokenAddress, string name, string symbol, uint256 amount);

    function stakeToken(string memory _name, string memory _symbol, uint _amount) public {
        whitelist.checkUser(toAsciiString(msg.sender));

        if (deployedTokenSymbolStrings[_symbol]) {
            ERC20Mintable t = ERC20Mintable(deployedTokenSymbolsToAddress[_symbol]);
            t.mint(_amount, msg.sender);
            treasury.awardProprietaryTokenForStaking(address(t), _amount, msg.sender);
        } else {
            ERC20Mintable t = new ERC20Mintable(_name, _symbol);
            deployedTokenAddresses.push(address(t));
            deployedTokenAddressesCheck[address(t)] = true;
            deployedTokenSymbolStrings[_symbol] = true;
            deployedTokenSymbolsToAddress[_symbol] = address(t);
            t.mint(_amount, msg.sender);
            treasury.awardProprietaryTokenForStaking(address(t), _amount, msg.sender);
        }
    }
}
