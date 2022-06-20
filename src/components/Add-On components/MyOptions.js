import React, { Component } from 'react'

class OptionsOverview extends Component {

render() {
    const { options } = this.props;

    return (
        <div id="content" className="mt-3">
            <div className="card mb-4" >
                <div className="card-body">
                    <div className='row'>
                        My Options: {options.length}
                    </div>
                    <hr/>
                    {options? (
                        <table>
                            <tr>
                                <th>
                                    Type
                                </th>
                                <th>
                                    Token
                                </th>
                                <th>
                                    Strike Price
                                </th>
                                <th>
                                    Amount
                                </th>
                                <th>
                                    Premium Value
                                </th>
                                <th>
                                    Duration
                                </th>
                                <th></th>
                            </tr>
                            {options.map((p) => {
                                return (
                                    <tr>
                                        <td>
                                            {p.isCall ? "Call" : "Put"}
                                        </td>
                                        <td>
                                            {p.token.title} ({p.token.symbol})
                                        </td>
                                        <td>
                                            {p.strikePrice}
                                        </td>
                                        <td>
                                            {p.amount}
                                        </td>
                                        <td>
                                            {p.premiumValue}
                                        </td>
                                        <td>
                                            {p.duration}
                                        </td>
                                        <td>
                                            <button type="submit" className="btn btn-primary btn-block btn-lg">Execute</button>
                                        </td>
                                    </tr>
                                );
                            })}
                        </table>
                        ) : null}
                </div>
            </div>
        </div>
    );
}
}

export default OptionsOverview;
