import React, { Component } from 'react';
import Web3 from 'web3';
import Navbar from './Navbar';
import Dex from './DEX components/Dex';
import PairCatalogue from './DEX components/PairCatalogue';
import './App.css';

import TokenFactory from '../abis/TokenFactory.json';
import ZuniswapV2Factory from '../abis/ZuniswapV2Factory.json';
import ZuniswapV2Pair from "../abis/ZuniswapV2Pair.json";

class App extends Component {

  async componentWillMount() {
    await this.loadWeb3()
    await this.loadBlockchainData()
  }

  async getPairsData(exchanges) {
    const b = [];
    return Promise.all(
      exchanges.map(async (e) => {
        const pair = new window.web3.eth.Contract(ZuniswapV2Pair.abi, e);
        const a = await pair.methods.getReserversWithTokenNames().call();
        const {0:token1Name, 1: token1Reserve, 2: token2Name, 3: token2Reserve} = a;
        b.push({
          token1Name,
          token1Reserve,
          token2Name,
          token2Reserve,
        });
        return a;
      })
    ).then(() => {
      return b;
    });
  }

  async loadBlockchainData() {
    const web3 = window.web3;
    const accounts = await web3.eth.getAccounts();
    this.setState({ account: accounts[0] });
    const networkId = await web3.eth.net.getId();

    // Load Factory
    const factoryData = ZuniswapV2Factory.networks[networkId];
    if(factoryData) {
      const factory = new web3.eth.Contract(ZuniswapV2Factory.abi, factoryData.address);
      const exchanges = await factory.methods.getAllPairs().call();
      const pairsData = await this.getPairsData(exchanges);
      this.setState({ exchanges });
      this.setState({ pairsData });
      this.setState({ factory });
    } else {
      window.alert('ZuniswapV2Factory contract not deployed to detected network.')
    }

    // Load TokenFactory
    const tokenFactoryData = TokenFactory.networks[networkId];
    if(tokenFactoryData) {
      const tokenFactory = new web3.eth.Contract(TokenFactory.abi, tokenFactoryData.address);
      this.setState({ tokenFactory });
    } else {
      window.alert('TokenFactory contract not deployed to detected network.')
    }
    this.setState({ loading: false })
  }

  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
    }
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider)
    }
    else {
      window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  }

  createExchange = async (name1, symbol1, amount1, name2, symbol2, amount2) => {
    this.setState({loading: true});
    await this.state.tokenFactory.methods.deployToken(name1, symbol1, amount1)
        .send({from: this.state.account});
    await this.state.tokenFactory.methods.deployToken(name2, symbol2, amount2)
        .send({from: this.state.account});
    const a = await this.state.tokenFactory.methods.getAllTokens().call();
    this.state.factory.methods.createPair(a[a.length - 2], a[a.length - 1])
        .send({from: this.state.account})
        .on('transactionHash', (hash) => {
          this.setState({loading: false})
        });
  }

  checkLibrary = async (factoryAddress, token0Address, token1Address) => {
    this.setState({loading: true});
    const a = await this.state.library.methods.getReserves(factoryAddress, token0Address, token1Address)
        .send({from: this.state.account})
        .on('transactionHash', (hash) => {
          this.setState({loading: false})
        });
    return a;
  }

  checkTokens = async () => {
    const a = await this.state.tokenFactory.methods.getAllTokens().call();
    console.log(a);
  }

  constructor(props) {
    super(props)
    this.state = {
      account: '0x0',
      factory: {},
      tokenFactory: {},
      exchanges: [],
      pairsData: [],
      library: {},
      loading: true
    }
  }

  render() {
    let content
    if(this.state.loading) {
      content = <p id="loader" className="text-center">Loading...</p>
    } else {
      content = <Dex
        createExchange={this.createExchange}
        checkTokens={this.checkTokens}
      />
    }

    return (
      <div>
        <Navbar account={this.state.account} />
        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 ml-auto mr-auto" style={{ maxWidth: '600px' }}>
              <div className="content mr-auto ml-auto">
                <a
                  href="http://www.dappuniversity.com/bootcamp"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                </a>

                {content}

                <hr/>

                <PairCatalogue
                    exchanges={this.state.exchanges}
                    checkLibrary={this.checkLibrary}
                    pairsData={this.state.pairsData}
                />
              </div>
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
