const ZuniswapPair = artifacts.require('ZuniswapV2Pair');
const ZuniswapFactory = artifacts.require('ZuniswapV2Factory');

const TokenFactory = artifacts.require('TokenFactory');
const AddOn = artifacts.require('JanusAddOn');
const ERC20Mintable = artifacts.require('ERC20Mintable');
const Whitelist = artifacts.require('Whitelist');
const Oracle = artifacts.require('Oracle');
const Treasury = artifacts.require('Treasury');

module.exports = async function(deployer, network, accounts) {

  // Deploy ZuniswapFactory
  const zuniswapFactory = await deployer.deploy(ZuniswapFactory);

  // Deploy ZuniswapPair
  await deployer.deploy(ZuniswapPair);

  // Deploy proprietary proprietaryToken
  const proprietaryToken = await deployer.deploy(ERC20Mintable, 'Janus Token', 'JAN');
  proprietaryToken.mint(100, proprietaryToken.address);

  // Deploy whitelist
  const whitelist = await deployer.deploy(Whitelist);
  whitelist.whitelistUser("0x6cDb5174A1074947E931f0FF903B0965961787D3");
  whitelist.whitelistUser("0x4eFaa619e9779160aE10b89c633eee9950a6c9cd");

  // Deploy oracle
  const oracle = await deployer.deploy(Oracle, proprietaryToken.address, whitelist.address);

  // Deploy treasury
  const treasury = await deployer.deploy(Treasury, proprietaryToken.address, oracle.address, whitelist.address);
  treasury.setAwardRate(100); // 100% reward rate

  // Deploy TokenFactory
  const tokenFactory = await deployer.deploy(TokenFactory, whitelist.address, treasury.address, proprietaryToken.address, oracle.address);
  tokenFactory.addToken(proprietaryToken.address);
  tokenFactory.setTotalAmountOfToken(proprietaryToken.address, 100);

  // Deploy add-on
  const addOn = await deployer.deploy(AddOn, proprietaryToken.address, whitelist.address, treasury.address, oracle.address);

  // Deploy demo option
  const amount = 10;
  const strikePrice = 1;
  const premiumValue = 2;
  const duration = '1 Day';
  const isCall = true;
  const userAddress = "0x6cDb5174A1074947E931f0FF903B0965961787D3";
  addOn.createOption(userAddress, proprietaryToken.address, amount, strikePrice, premiumValue, duration, isCall);
}
