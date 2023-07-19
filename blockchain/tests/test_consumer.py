import pytest

from brownie import Token, accounts

@pytest.fixture
def token_contract():
    # Deploy the contract
    return accounts[0].deploy(Token)

def consumer_purchase_token(token_contract):
    minter = token_contract.minter()
    test_producer = accounts[1]
    test_consumer = accounts[2]
    
    # Mint a new token
    tx = token_contract.mint(test_producer, {'from': minter})
    token_id = tx.return_value
    
    # Conasumer purchase of the token
    token_contract.consumerPurchaseToken(token_id, test_consumer, 100)
    