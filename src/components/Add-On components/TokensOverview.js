import React, { Component } from 'react'

class TokensOverview extends Component {

render() {
    const { tokens } = this.props;

    return (
        <div id="content" className="mt-3">
            <div className="card mb-4" >
                <div className="card-body">
                    <div className='row'>
                        Tokens Deployed: {tokens.length}
                    </div>
                    <hr/>
                    {tokens? (
                        tokens.map((p) => {
                            return (
                                <div key={p.title} className='row'>
                                    <div className='col-4'>
                                        <b>{p.title}:</b>
                                    </div>
                                    <div className='col-6'>
                                        {p.symbol}
                                        {' '}
                                        {p.amount}
                                    </div>
                                </div>
                            );
                        })) : null}
                </div>
            </div>
        </div>
    );
}
}

export default TokensOverview;
