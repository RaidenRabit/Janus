// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

interface   IOptionsStruct {
    struct Token {
        address tokenAddress;
        string title;
        string symbol;
    }

    struct Option  {
        uint ID;
        Token token; // the asset that's being traded
        uint amount; // amount agreed on the contract
        uint strikePrice; // agreed price of the asset (per asset)
        uint premiumValue; // price of the option
        string duration; // expiration date
        bool isCall;
        address buyerAddress; // who bought this (long)
        address sellerAddress; // who sold it (short)
    }
}
