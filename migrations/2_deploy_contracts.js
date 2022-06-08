const Pair = artifacts.require('ZuniswapV2Pair');
const Factory = artifacts.require('ZuniswapV2Factory');
const TokenFactory = artifacts.require('TokenFactory');
const AddOn = artifacts.require('JanusAddOn');
const ERC20Mintable = artifacts.require('ERC20Mintable');
const Whitelist = artifacts.require('Whitelist');

module.exports = async function(deployer, network, accounts) {
  // Deploy Factory
  await deployer.deploy(Factory);

  // Deploy Pair
  await deployer.deploy(Pair);

  // Deploy TokenFactory
  const factory = await deployer.deploy(TokenFactory);

  // Deploy proprietary token
  const token = await deployer.deploy(ERC20Mintable, 'Janus Token', 'JAN');
  token.mint(100, token.address);
  factory.addToken(token.address);

  // Deploy whitelist
  const whitelist = await deployer.deploy(Whitelist);
  whitelist.whitelistUser("0x4b06937dD92a20FD76c14bdD69C98B64491CdA83");
  //
  // // Deploy add-on
  // const addOn = await deployer.deploy(AddOn, token, whitelist);
  //
  // // link factory to add-on
  // factory.setAddOnAddress(addOn.address);
}
