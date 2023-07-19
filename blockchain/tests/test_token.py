import pytest

from brownie import Token, accounts

EMPTY_ADDRESS = '0x0000000000000000000000000000000000000000'

@pytest.fixture
def token_contract():
    # Deploy the contract
    return accounts[0].deploy(Token)

def test_initial_state(token_contract):
    # Check if the constructor of the contract is set up properly
    assert token_contract.minter() == accounts[0]
    assert token_contract.tokenCount() == 0

def test_mint_burn(token_contract):
    minter = token_contract.minter()
    test_producer = accounts[1]
    token_count = token_contract.tokenCount()
    
    # Mint a token and associate it with a producer
    tx = token_contract.mint(test_producer, {'from': minter})
    token_id = tx.return_value
    assert token_contract.tokenCount() == token_count + 1
    assert token_contract.producerOf.call(token_id, {'from': minter}) == test_producer.address
    
    # Burn a token and check that it is no longer associated with a producer
    token_contract.burn(token_id, {'from': test_producer})
    assert token_contract.tokenCount() == token_count
    assert token_contract.producerOf.call(token_id, {'from': minter}) == EMPTY_ADDRESS
