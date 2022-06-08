import React, { Component } from 'react'

import ZuniswapV2Pair from '../../abis/ZuniswapV2Pair.json';

class CreateFuturesView extends Component {

render() {
    const { exchanges, checkLibrary, pairsData } = this.props;
    const { web3 } = window;
    console.log(pairsData);

    return (
        <div id="content" className="mt-3">
            <div className="card mb-4" >
                <div className="card-body">
                    <div className='row'>
                        exchange addresses: {exchanges.length}
                    </div>
                    <hr/>
                    {pairsData? (
                        pairsData.map((p) => {
                            return (
                                <div className='row'>
                                    <div className='col-2'>
                                        <b>{p.token1Name}:</b> {p.token1Reserve}
                                    </div>
                                    <div className='col-2'>
                                        <b>{p.token2Name}:</b> {p.token2Reserve}
                                    </div>
                                </div>
                            );
                        })) : ''}
                </div>
            </div>
        </div>
    );
}
}

export default CreateFuturesView;
