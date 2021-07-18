---
tip: 7
title: TRC-7 NFT Standard
author: Anton Platonov <anton@platonov.us>, Dmitriy Yankin <d.s.yankin@gmail.com>
type: Standards Track
category: TRC
status: Pending
created: 2021-07-16
---

# Simple Summary

A standard interface for non-fungible tokens.

Standard covers a `Token`, single contract with internal or external media and a `Collection`, a `Token` creator (but not owner) and a logical pattern/specification to group `Tokens`.

`Token` is created as empty vessel, Owner then needs to upload its content and "seal" it to be able to sell or transfer it. This way 16 Kb upload limit to the blockchain (for on-chain media storage) can be surpassed.

NOTE: `Collection` is not a wallet, `Collection` aims only to group similar kinds of `Tokens`.

# Abstract

The following standard allows for the implementation of a standard API for non-fungible tokens within smart contracts.
This standard provides basic functionality to transfer and manage tokens.


# Motivation

A standard interface allows any tokens on Free TON blockchain to be re-used by other applications: from wallets to decentralized exchanges.
Comparing to TIP-3 NFT TRC-7:
 * Respects asynchronous nature of Free TON blockchain (includes callbacks and callback getters);
 * Covers only one type of Token instead of 4;
 * Follows "one Token = one Contract" paradigm;
 * Can have only internal owners;
 * Doesn't require the owner to worry about Token balances (with one exception);

# Specification

# Token + Collection
## Methods

**NOTES**:
 - The following specifications use syntax from TON Solidity `0.47.0` (or above)


### getInfo
### callInfo

Returns the NFT information using the following structure:

``` js
struct nftInfo
{
    uint32  dtCreated;
    address ownerAddress;
    address authorAddress;
}
```

`dtCreated` - NFT creation date in UNIX time.

`ownerAddress` - Address of the current NFT owner. Can only be another contract's address (Multisig is preferred), can't be external (e.g. Public Key).

`authorAddress` - Address of the NFT creator, can't be changed.


``` js
function  getInfo() external             view         returns (nftInfo);
function callInfo() external responsible view reserve returns (nftInfo);
```


### getMedia
### callMedia

Returns the NFT information using the following structure:

``` js
struct nftMedia
{
    bytes[] contents;
    bytes   extension;
    bytes   name;
    bytes   comment;
    bool    isSealed;
}
```

`contents` - NFT contents. Either binary file (every array item represents a chunk in binary hex), or arbitrary link/hash to NFT media.

`extension` - Type of the contents: extension for binary files (e.g. `gif`, `png`, `mp4` etc.) or type for the link/hash (e.g. `#url`, `#hash`, `#address` etc.).

`name` - Name of the token, e.g. `Mona Lisa`.

`comment` - Arbitrtary comment of the token.

`isSealed` - Sealing means finalizing token contents. Sealed token can't be changed anymore. Sealed token can be transfered to another owner.


``` js
function  getMedia() external             view returns (nftMedia);
function callMedia() external responsible view returns (nftMedia);
```


### getOwnerAddress
### callOwnerAddress

Returns current owner address.

``` js
function  getOwnerAddress() external             view returns (address);
function callOwnerAddress() external responsible view returns (address);
```


### changeOwner
### callChangeOwner

Transfers ownership of the NFT to `newOwnerAddress`. NFT needs to have attribute `isSealed` to perform the transfer.

ACCESS: only `Token`/`Collection` owner;

``` js
function changeOwner    (address newOwnerAddress) external             returns (address oldAddress, address newAddress)
function callChangeOwner(address newOwnerAddress) external responsible returns (address oldAddress, address newAddress)
```


### Events

TODO


# Token
## Methods

### getTokenID
### callTokenID

Returns current `Token` ID.

``` js
function  getTokenID() external             view returns (uint128);
function callTokenID() external responsible view returns (uint128);
```


### getCollectionAddress
### callCollectionaddress

Returns `Token's` `Collection` address.

``` js
function  getCollectionAddress() external             view returns (address);
function callCollectionaddress() external responsible view returns (address);
```


# Collection
## Methods

### getTokenCode
### callTokenCode

Returns `Token's` code.

``` js
function  getTokenCode() external view             returns (TvmCell);
function callTokenCode() external responsible view returns (TvmCell);
```


### getTokensIssued
### callTokensIssued

Returns number of issued `Tokens` for this `Collection`.

``` js
function  getTokensIssued() external view             returns (uint128);
function callTokensIssued() external responsible view returns (uint128);
```


### getCollectionName
### callCollectionName

Returns `Collection` name.

``` js
function  getCollectionName() external view             returns (bytes);
function callCollectionName() external responsible view returns (bytes);
```


### createEmptyNFT

Creates empty `Token`; Owner can then upload internal/external media to it and seal it for sale/transfer.

ACCESS: only `Collection` owner;

``` js
function createEmptyNFT(uint256 uploaderPubkey) external returns (address);
```


## Implementation

Interface is in `interfaces` folder.

`Liquid contracts` `Collection` and `Token` implementation in `contracts` folder.


## History

TODO



## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).