// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "./mocks/ERC20Mintable.sol";
import "./JanusAddOn.sol";

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


    address[] deployedContracts;
    mapping(address => bool) public deployedContractsCheck;
    address public addOnAddress = address(0);

    function setAddOnAddress(address _address) public {
        if (addOnAddress == address(0)) {
            addOnAddress = _address;
        }
    }

    function getAllTokens() public view returns(address[] memory) {
        return deployedContracts;
    }

    function addToken(address _token) public {
        if(!deployedContractsCheck[_token]) {
            deployedContracts.push(_token);
            deployedContractsCheck[_token] = true;
        }
    }

    event TokenDeployed(address tokenAddress, string name, string symbol, uint256 amount);

    function deployToken(string memory name_, string memory symbol_, uint256 amount_) public returns(address) {
        ERC20Mintable t = new ERC20Mintable(name_, symbol_);
        deployedContracts.push(address(t));
        deployedContractsCheck[address(t)] = true;
        t.mint(amount_, address(t));
        if (addOnAddress != address(0)) {
            JanusAddOn addOn = JanusAddOn(addOnAddress);
            addOn.awardProprietaryTokenForStaking(amount_, msg.sender, toAsciiString(msg.sender));
        }
        emit TokenDeployed(address(t), t.getName(), t.getSymbol(), t.balanceOf(address (t)));
        return address(t);
    }
}
