# Smart Contract

## Setting up MetaMask and MyEtherWallet

1. Install the MetaMask browser extension and create a wallet: https://metamask.io/download/
2. Fund the wallet with test ETH using a Sepolia faucet: https://sepoliafaucet.com/
3. Go to https://www.myetherwallet.com/wallet/access > `Browser extension`. The MetaMask wallet should successfuly integrate with MyEtherWallet

## Environment Setup

1. Create a new Python virtual environment: `python -m venv venv`
2. Activate the Python virtual environment: `source venv/bin/activate`
3. Install the required libraries: `pip install -r requirements.txt`

## Compile the Contract

1. Generate the smart contract bytecode: `vyper Tokens.vy`
2. Generate the smart contract ABI: `vyper -f abi Tokens.vy`

## Deploy the Contract

1. Go to https://www.myetherwallet.com/wallet/deploy > `Contract` > `Interact with Contract`
2. Select the `Sepolia Testnet` network
3. Paste the smart contract `Bytecode` and `ABI` that were generated when compiling the contracts into the appropriate fields, and provide a `Contract name`
4. `Sign transaction`

## Automated Tests

1. Install Ganache globally: `npm install -g ganache`
2. Run `brownie test`
