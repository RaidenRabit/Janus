import React, { Component } from 'react'

class CreateOptions extends Component {

render() {
    const { tokens } = this.props;

    return (
        <div id="content" className="mt-1">
            <div className="card mb-12" >
                <div className="card-body">
                    <div className='row'>
                        Create Options
                    </div>
                    <hr/>
                    {tokens ? (

                        <form className="mb-3" onSubmit={(event) => {
                            event.preventDefault();
                            let isCall;
                            let tokenAddress;
                            let duration;
                            let amount;
                            let strikePrice;
                            let premiumValue;
                            isCall = document.getElementById("isCall").checked;;
                            tokenAddress = document.getElementById('tokenSelector').value;
                            duration = document.getElementById('durationSelector').value;
                            amount = this.amount.value.toString();
                            strikePrice = this.strikePrice.value.toString();
                            premiumValue = this.premiumValue.value.toString();
                            this.props.createOptions(isCall, tokenAddress, duration, amount, strikePrice, premiumValue);
                        }}>
                            <div className='row'>
                                <div className='col-2'>
                                    <div className='row'>
                                        <div className='col-2'>
                                            <label>isCall?</label>
                                        </div>
                                    </div>
                                    <div className='row'>
                                        <div className='col-2'>
                                            <input
                                                ref={(isCall) => { this.isCall = isCall }}
                                                type="checkbox" id="isCall" name="isCall" value="isCall"/>
                                        </div>
                                    </div>
                                </div>
                                <div className='col-5'>
                                    <div className='row'>
                                        <div className='col-2'>
                                            <label>Token</label>
                                        </div>
                                    </div>
                                    <div className='row'>
                                        <div className='col-2'>
                                            <select id='tokenSelector'>
                                                {tokens.map((t) => (
                                                    <option value={t.address}>{t.amount} {t.title} ({t.symbol})</option>
                                                ))}
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div className='col-5'>
                                    <div className='row'>
                                        <div className='col-2'>
                                            <label>Duration</label>
                                        </div>
                                    </div>
                                    <div className='row'>
                                        <div className='col-5'>
                                            <select id='durationSelector'>
                                                <option value={1}>1 Day</option>
                                                <option value={2}>2 Day</option>
                                                <option value={3}>3 Day</option>
                                                <option value={7}>7 Day</option>
                                                <option value={15}>15 Day</option>
                                                <option value={30}>30 Day</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <br/>
                            <div className='row'>
                                <div className="input-group mb-12">
                                    <input
                                        type="number"
                                        ref={(amount) => { this.amount = amount }}
                                        className="form-control form-control-lg"
                                        placeholder="Amount"
                                        required />
                                    <input
                                        type="number"
                                        ref={(strikePrice) => { this.strikePrice = strikePrice }}
                                        className="form-control form-control-lg"
                                        placeholder="Strike Price"
                                        required />
                                </div>
                            </div>
                            <br/>
                            <div className='row'>
                                <div className='input-group mb-12'>
                                    <input
                                        type="number"
                                        ref={(premiumValue) => { this.premiumValue = premiumValue }}
                                        className="form-control form-control-lg"
                                        placeholder="Premium Value"
                                        required />
                                </div>
                            </div>
                            <br/>
                            <div className='row'>
                                <button type="submit" className="btn btn-primary btn-block btn-lg">Sell</button>
                            </div>
                        </form>
                    ) : null}
                </div>
            </div>
        </div>
    );
}
}

export default CreateOptions;
