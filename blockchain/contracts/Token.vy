# @dev Implementation of user data tokens, based on the ERC-721 non-fungible token standard.
# @author William Park
# Based on https://github.com/vyperlang/vyper/blob/master/examples/tokens/ERC721.vy

# @version ^0.3.7

### EVENTS ###

# @dev Emits when a token is minted.
# @param tokenId The identifier for the new token.
# @param producer The address of producer the data token is associated with.
event Mint:
    tokenId: uint256
    producer: indexed(address)

# @dev Emits when a token is burned.
# @param tokenId The identifier for the burned token.
# @param producer The address of producer the data token is associated with.
event Burn:
    tokenId: uint256
    producer: indexed(address)

# @dev Emits when a token is purchased by a consumer.
# @param tokenId The identifier for the token.
# @param consumer The address of consumer who purchased the token.
event Purchase:
    tokenId: uint256
    consumer: indexed(address)

# @dev Emits when a token subscription is cancelled by a consumer.
# @param tokenId The identifier for the token.
# @param consumer The address of consumer who cancelled their subcription.
event Cancel:
    tokenId: uint256
    consumer: indexed(address)

# @dev Emits when a token subscription is revoked for a consumer.
# @param tokenId The identifier for the token.
# @param consumer The address of consumer whose subscription was revoked.
event Revoke:
    tokenId: uint256
    consumer: indexed(address)

### CONSTANTS AND STORAGE VARIABLES ###

# @dev The maximum number of tokens that one consumer could subscribe to.
MAX_TOKENS_PER_CONSUMER: constant(uint256) = 1024

# @dev The maximum number of consumers who can subscribe to one token.
MAX_CONSUMERS_PER_TOKEN: constant(uint256) = 1024

# @dev Address of minter, who can mint a token.
minter: public(address)

# @dev The number of total tokens that have been created.
tokenCount: public(uint256)

# @dev Mapping from token ID to the producer address whose data it is associated with.
idToProducer: HashMap[uint256, address]

# @dev Mapping from consumer address to the tokens that they have purchased.
consumerToTokenIds: HashMap[address, DynArray[uint256, MAX_TOKENS_PER_CONSUMER]]

# @dev Mapping from token ID to the consumers who have purchased it.
tokenIdToConsumers: HashMap[uint256, DynArray[address, MAX_CONSUMERS_PER_TOKEN]]

# @dev Mapping from consumer address to the tokens they have purchased as well as the subscription end date.
consumerToSubscriptionTerms: HashMap[address, HashMap[uint256, uint256]]

### FUNCTIONS ###

@external
def __init__():
    """
    @dev Contract constructor.
    """
    self.minter = msg.sender
    self.tokenCount = 0

### PRODUCER PERMISSION HELPERS ###

@internal
def _producerOf(_tokenId: uint256) -> address:
    """
    @dev Returns the producer of the token associated with `_tokenId`.
         Throws if `_tokenId` is invalid.
         Throws if the the token has no associated producer.
    @param _tokenId The identifier for a token.
    @return The address of the token producer.
    """
    assert _tokenId > 0
    producer: address = self.idToProducer[_tokenId]

    return producer

@internal
def _isProducerOf(_tokenId: uint256, _producer: address) -> bool:
    """
    @dev Returns if a producer is the owner of a token.
         Throws if `_tokenId` is invalid or `_producer` is the zero address.
    @param _tokenId The identifier for a token.
    @param _producer The address of the producer.
    @return A boolean representing whether the producer is the token owner.
    """
    assert _tokenId > 0 and _producer != empty(address)

    return _producer == self._producerOf(_tokenId)

@internal
def _createProducerToken(_tokenId: uint256, _producer: address):
    """
    @dev Create a token for the specified producer.
         Throws if `_tokenId` is invalid or `_producer` is the zero address.
         Throws if `_producer` already has an associated token.
    @param _tokenId The identifier for a token.
    @param _producer The address of the producer.
    """
    assert _tokenId > 0 and _producer != empty(address)
    assert self.idToProducer[_tokenId] == empty(address)

    self.idToProducer[_tokenId] = _producer

@internal
def _removeProducerToken(_tokenId: uint256):
    """
    @dev Remove the association between a token and its producer.
         Throws if `_tokenId` is invalid.
         Throws if `_tokenId` has no producer initially.
    @param _tokenId The identifier for a token.
    """
    assert _tokenId > 0
    assert self.idToProducer[_tokenId] != empty(address)

    self.idToProducer[_tokenId] = empty(address)

### CONSUMER PERMISSION HELPERS ###

@internal
def _hasConsumerAccessRights(_tokenId: uint256, _consumer: address) -> bool:
    """
    @dev Returns if a consumer's subscription term for a token is still valid.
         Throws if `_tokenId` is invalid or `_consumer` is the zero address.
         Throws if `_consumer` is not subscribed to `_tokenId`.
    @param _tokenId The identifier for a token.
    @param _consumer The address of the consumer.
    @return A boolean representing whether the consumer has access rights to the token.
    """
    assert _tokenId > 0 and _consumer != empty(address)
    subscriptionEnd: uint256 = (self.consumerToSubscriptionTerms[_consumer])[_tokenId]
    assert subscriptionEnd != 0

    return subscriptionEnd <= block.timestamp

@internal
def _addConsumerAccess(_tokenId: uint256, _consumer: address, _subscriptionLength: uint256):
    """
    @dev Add a consumer to the list of those who purchased access rights for a token, along with the subscription length.
         Throws if `_tokenId` is invalid, `_consumer` is the zero address, or `_subscriptionLength` is invalid.
         Throws if `_tokenId` has no producer.
    @param _tokenId The identifier for a token.
    @param _consumer The address of the consumer.
    @param _subscriptionLength The length of the purchased subscription.
    """
    assert _tokenId > 0 and _consumer != empty(address) and _subscriptionLength > 0
    assert self.idToProducer[_tokenId] != empty(address)

    # Consumer-token relationship
    self.consumerToTokenIds[_consumer].append(_tokenId)
    self.tokenIdToConsumers[_tokenId].append(_consumer)

    # Subscription term
    currentTime: uint256 = block.timestamp
    self.consumerToSubscriptionTerms[_consumer][_tokenId] = currentTime + _subscriptionLength

@internal
def _removeConsumerAccess(_tokenId: uint256, _consumer: address):
    """
    @dev Remove all associations between a token and a consumer who had previously purchased the token.
         Throws if `_tokenId` is invalid or `_consumer` is the zero address.
         Throws if `_consumer` is not currently a consumer for `_tokenId`
    @param _tokenId The identifier for a token.
    @param _consumer The address of the consumer.
    """
    assert _tokenId > 0 and _consumer != empty(address)
    assert self.consumerToSubscriptionTerms[_consumer][_tokenId] != 0

    tokens: DynArray[uint256, MAX_TOKENS_PER_CONSUMER] = self.consumerToTokenIds[_consumer]
    for i in range(MAX_TOKENS_PER_CONSUMER):
        if tokens[i] == _tokenId:
            self.consumerToTokenIds[_consumer][i] = self.consumerToTokenIds[_consumer][len(self.consumerToTokenIds[_consumer]) - 1]
            self.consumerToTokenIds[_consumer].pop()
            break

    consumers: DynArray[address, MAX_CONSUMERS_PER_TOKEN] = self.tokenIdToConsumers[_tokenId]
    for i in range(MAX_CONSUMERS_PER_TOKEN):
        if consumers[i] == _consumer:
            self.tokenIdToConsumers[_tokenId][i] = self.tokenIdToConsumers[_tokenId][len(self.tokenIdToConsumers[_tokenId]) - 1]
            self.tokenIdToConsumers[_tokenId].pop()
            break

    self.consumerToSubscriptionTerms[_consumer][_tokenId] = 0

@internal
def _removeConsumerExpiredSubscriptions(_consumer: address):
    """
    @dev Removes a consumer's expired subscriptions.
         Throws if `_consumer` is the zero address.
    @param _consumer The address of the consumer.
    """
    assert _consumer != empty(address)

    tokens: DynArray[uint256, MAX_TOKENS_PER_CONSUMER] = self.consumerToTokenIds[_consumer]
    for tokenId in tokens:
        if not self._hasConsumerAccessRights(tokenId, _consumer):
            self._removeConsumerAccess(tokenId, _consumer)

@internal
def _removeTokenExpiredSubscriptions(_tokenId: uint256):
    """
    @dev Removes a token's expired consumer subscriptions.
         Throws if `_tokenId` is invalid.
    @param _tokenId The identifier for a token.
    """
    assert _tokenId > 0

    consumers: DynArray[address, MAX_CONSUMERS_PER_TOKEN] = self.tokenIdToConsumers[_tokenId]
    for consumer in consumers:
        if not self._hasConsumerAccessRights(_tokenId, consumer):
            self._removeConsumerAccess(_tokenId, consumer)

### PRODUCER TOKENS ###

@external
def producerOf(_tokenId: uint256) -> address:
    """
    @dev Returns the producer of the token associated with `_tokenId`.
         Throws if `_tokenId` is invalid.
         Throws if the the token has no associated producer.
    @param _tokenId The identifier for a token.
    @return The address of the token producer.
    """

    return self._producerOf(_tokenId)

### CONSUMER TOKEN SUBSCRIPTIONS ###

@external
def consumerTokens(_consumer: address) -> DynArray[uint256, MAX_TOKENS_PER_CONSUMER]:
    """
    @dev Returns the token IDs purchased by a consumer.
    @param _consumer The address of the consumer.
    @return An array of all the tokens the consumer has purchased access rights to.
    """
    self._removeConsumerExpiredSubscriptions(_consumer)

    return self.consumerToTokenIds[_consumer]

@external
def tokenConsumers(_tokenId: uint256) -> DynArray[address, MAX_CONSUMERS_PER_TOKEN]:
    """
    @dev Returns the consumers who have purchased access rights to a token.
         Throws if `_tokenId` is invalid.
    @param _tokenId The identifier for a token.
    @return An array of all the consumers that have purchased access rights to the token.
    """
    self._removeTokenExpiredSubscriptions(_tokenId)

    return self.tokenIdToConsumers[_tokenId]

### CONSUMER ACTIONS ###

@payable
@external
def consumerPurchaseToken(_tokenId: uint256, _consumer: address, _subscriptionLength: uint256):
    """
    @dev Consumer purchases access rights to a token for a specified subscription length.
         Throws if `_tokenId` is invalid, `_consumer` is the zero address, or `_subscriptionLength` is invalid.
         Throws if `_tokenId` has no producer.
         Throws if the address interacting with the contract is not `_consumer`.
         Throws if `_consumer` already has access rights to the token.
    @param _tokenId The identifier for a token.
    """
    assert _tokenId > 0 and _consumer != empty(address) and _subscriptionLength > 0
    assert self.idToProducer[_tokenId] != empty(address)
    assert msg.sender == _consumer
    assert not self._hasConsumerAccessRights(_tokenId, _consumer)
    
    self._addConsumerAccess(_tokenId, _consumer, _subscriptionLength)

    log Purchase(_tokenId, _consumer)

@external
def consumerCancelToken(_tokenId: uint256, _consumer: address):
    """
    @dev Consumer cancels access rights to a token they had previously purchased.
         Throws if `_tokenId` is invalid or `_consumer` is the zero address.
         Throws if `_tokenId` has no producer.
         Throws if the address interacting with the contract is not `_consumer`.
         Throws if `_consumer` does not already have access rights to the token.
    @param _tokenId The identifier for a token.
    """
    assert _tokenId > 0 and _consumer != empty(address)
    assert self.idToProducer[_tokenId] != empty(address)
    assert msg.sender == _consumer
    assert self._hasConsumerAccessRights(_tokenId, _consumer)
    
    self._removeConsumerAccess(_tokenId, _consumer)

    log Cancel(_tokenId, _consumer)

### MINT & BURN FUNCTIONS ###

@external
def mint(_producer: address) -> uint256:
    """
    @dev Function to mint tokens
         Throws if `msg.sender` is not the minter.
         Throws if `_producer` is the zero address.
    @param _producer The address that will receive the minted token.
    @return The created token ID.
    """
    assert msg.sender == self.minter
    assert _producer != empty(address)

    self.tokenCount += 1
    self._createProducerToken(self.tokenCount, _producer)

    log Mint(self.tokenCount, _producer)
    
    return self.tokenCount

@external
def burn(_tokenId: uint256):
    """
    @dev Burns a specific token.
         Throws if `_tokenId` is invalid.
         Throws if `_tokenId` has no producer.
         Throws if the address interacting with the contract is not the producer of the token.
    @param _tokenId The identifier for a token to be burned.
    """
    assert _tokenId > 0
    producer: address = self.idToProducer[_tokenId]
    assert producer != empty(address)
    assert self._isProducerOf(_tokenId, msg.sender)

    consumers: DynArray[address, MAX_CONSUMERS_PER_TOKEN] = self.tokenIdToConsumers[_tokenId]
    for consumer in consumers:
        self._removeConsumerAccess(_tokenId, consumer)
        log Revoke(_tokenId, consumer)

    self._removeProducerToken(_tokenId)

    self.tokenCount -= 1
    log Burn(_tokenId, producer)
