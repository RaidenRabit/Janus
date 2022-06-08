# Janus a DEX implementation made in educational purposes

## Using this repo

1. install project dependencies by running: `npm install`
2. Ensure you have installed Rust and Cargo: [Install Rust](https://www.rust-lang.org/tools/install)
3. Install Foundry:
   `cargo install --git https://github.com/gakonst/foundry --bin forge --locked foundry-cli`
4. Install dependency contracts:
   `git submodule update --init --recursive`
5. Run tests:
   `run the 'test contracts' script from the package.json`

## Running the webclient
1. `install ganache with the istanbul fork`
2. `install metamask and connect it to your ganache network`
3. `deploy the contracts by running the 'deploy contracts' script from package.json`
4. `run the start script from package.json`
