import React, { Component } from 'react';

class Dex extends Component {

    render() {
        return (
            <div id="content" className="mt-3">

                <div className="card mb-4">
                    <div className="card-body">
                        <button onClick={() => {this.props.checkTokens()}}
                                className="btn btn-secondary">Check Tokens</button>
                    </div>
                </div>

                <div className="card mb-4" >

                    <div className="card-body">

                        <form className="mb-3" onSubmit={(event) => {
                            event.preventDefault();
                            let name1;
                            let symbol1;
                            let amount1;
                            let name2;
                            let symbol2;
                            let amount2;
                            name1 = this.name1.value.toString();
                            symbol1 = this.symbol1.value.toString();
                            amount1 = this.amount1.value.toString();
                            amount1 = window.web3.utils.toWei(amount1, 'Ether');
                            name2 = this.name2.value.toString();
                            symbol2 = this.symbol2.value.toString();
                            amount2 = this.amount2.value.toString();
                            amount2 = window.web3.utils.toWei(amount2, 'Ether');
                            this.props.createExchange(name1, symbol1, amount1, name2, symbol2, amount2);
                        }}>
                            <div>
                                <label className="float-left"><b>Exchanges</b></label>
                                <span className="float-right text-muted">
                </span>
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(name) => { this.name1 = name }}
                                    className="form-control form-control-lg"
                                    placeholder="Token Name"
                                    required />
                                <input
                                    type="text"
                                    ref={(symbol) => { this.symbol1 = symbol }}
                                    className="form-control form-control-lg"
                                    placeholder="Token Symbol"
                                    required />
                                <input
                                    type="text"
                                    ref={(amount) => { this.amount1 = amount }}
                                    className="form-control form-control-lg"
                                    placeholder="Initial Amount"
                                    required />
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(name) => { this.name2 = name }}
                                    className="form-control form-control-lg"
                                    placeholder="Token Name"
                                    required />
                                <input
                                    type="text"
                                    ref={(symbol) => { this.symbol2 = symbol }}
                                    className="form-control form-control-lg"
                                    placeholder="Token Symbol"
                                    required />
                                <input
                                    type="text"
                                    ref={(amount) => { this.amount2 = amount }}
                                    className="form-control form-control-lg"
                                    placeholder="Initial Amount"
                                    required />
                            </div>
                            <button type="submit" className="btn btn-primary btn-block btn-lg">Create Exchange</button>
                        </form>
                    </div>
                </div>

            </div>
        );
    }
}

export default Dex;
