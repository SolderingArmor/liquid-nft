---
tip: 7
title: TRC-7 NFT Standard
author: Anton Platonov <anton@platonov.us>
type: Standards Track
category: TRC
status: Pending
created: 2021-07-16
---

# Simple Summary

A standard interface for non-fungible tokens.

Standard covers a `Token`, single contract with internal or external media and a `Collection`, a `Token` creator (but not owner) and a logical pattern/specification to group `Tokens`.

Standart also includes a way to create generative art distibutor aka `Distributor`.

NOTE: `Collection` is not a wallet, `Collection` aims only to group similar kinds of `Tokens`. Think of it as artist's collection.

# Abstract

The following standard allows for the implementation of a standard API for non-fungible tokens within smart contracts.
This standard provides basic functionality to transfer and manage tokens.

# Motivation

A standard interface allows any tokens on Everscale blockchain to be re-used by other applications: from wallets to decentralized exchanges.
This standard:
 * Respects asynchronous nature of Everscale blockchain (includes callbacks and callback getters);
 * Covers only the `Token` without auction or complex logic built in (UNIX way);
 * Follows `one Token = one Contract` paradigm;
 * Follows KISS paradigm;
 * Can have only internal owners (addresses);
 * Doesn't require the owner to worry about `Token` balances (gas management);
 * Keeps all the structure in JSON format, this allows to have different data standards without the need to change token code;

## Specification

## Token
### Methods

#### getInfo
#### callInfo

Returns `Token` information.

| Parameter | Description |
|-----------|-------------|
| `includeMetadata` | If metadata should be included |

Return values:

| Parameter | Description |
|-----------|-------------|
| `collectionAddress` | Token collection address |
| `tokenID` | Token ID |
| `ownerAddress` | NFT owner |
| `creatorAddress` | NFT creator |
| `primarySaleHappened` | If 100% of the first sale should be distributed between the creators list |
| `metadataContents` | Token metadata in JSON format |
| `metadataIsMutable` | Boolean if metadata is mutable and can be changed |
| `metadataAuthorityAddress` | Address of an authority who can update metadata (if it is mutable) |
| `masterEditionSupply` | Current amount of copies if the token can be printed |
| `masterEditionMaxSupply` | Maximum amount of copies if the token can be printed |
| `masterEditionPrintLocked` | If print is available or locked |
| `editionNumber` | Master edition (original token) always has `editionNumber` = 0, printed versions have 1+ |
| `creatorsPercent` | Defines how many percent creators get when NFT is sold on a secondary market |
| `creatorsShares` | Defines a list of creators with their shares |

``` solidity
struct CreatorShare
{
    address creatorAddress; // 
    uint8   creatorShare;   // 1 = 1% share
}

function getInfo(bool includeMetadata) external view returns (
    address        collectionAddress,
    uint256        tokenID,
    address        ownerAddress,
    address        creatorAddress,
    bool           primarySaleHappened,
    string         metadataContents,
    bool           metadataIsMutable,
    address        metadataAuthorityAddress,
    uint256        masterEditionSupply,
    uint256        masterEditionMaxSupply,
    bool           masterEditionPrintLocked,
    uint256        editionNumber,
    uint16         creatorsPercent,
    CreatorShare[] creatorsShares);

function callInfo(bool includeMetadata) external responsible view returns (
    address        collectionAddress,
    uint256        tokenID,
    address        ownerAddress,
    address        creatorAddress,
    bool           primarySaleHappened,
    string         metadataContents,
    bool           metadataIsMutable,
    address        metadataAuthorityAddress,
    uint256        masterEditionSupply,
    uint256        masterEditionMaxSupply,
    bool           masterEditionPrintLocked,
    uint256        editionNumber,
    uint16         creatorsPercent,
    CreatorShare[] creatorsShares);
```

#### setOwner

Changes NFT owner.

| Parameter | Description |
|-----------|-------------|
| `ownerAddress` | New owner address |

``` solidity
function setOwner(address ownerAddress) external;
```

#### setOwnerWithPrimarySale

Changes NFT owner and flips `primarySaleHappened` flag to `true`.

| Parameter | Description |
|-----------|-------------|
| `ownerAddress` | New owner address |

``` solidity
function setOwnerWithPrimarySale(address ownerAddress) external;
```

#### setMetadata

Changes NFT metadata if `metadataIsMutable` is `true`.

| Parameter | Description |
|-----------|-------------|
| `metadataContents` | New metadata in JSON format |

``` solidity
function setMetadata(string metadataContents) external;
```

#### lockMetadata

Locks NFT metadata.

``` solidity
function lockMetadata() external;
```

#### printCopy

Prints a copy of the NFT.
Sometimes when you need multiple copies of the same NFT you can.. well..
create multiple copies of the same NFT (like coins or medals etc.) 
and they will technically different NFTs but at the same time logically 
they will be the same. Printing allows you to have multiple copies of the 
same NFT (with the same `tokenID`) distributed to any number of people. Every
one of them will be able to sell or transfer their own copy.

| Parameter | Description |
|-----------|-------------|
| `targetOwnerAddress` | Address who receives a print |

``` solidity
function printCopy(address targetOwnerAddress) external;
```

#### lockPrint

Locks NFT printing.

``` solidity
function lockPrint() external;
```

#### destroy

Destroys NFT.
WARNING! This can not be undone!

``` solidity
function destroy() external;
```

### Events

#### ownerChanged

Emitted when NFT owner is changed.

| Parameter | Description |
|-----------|-------------|
| `oldOwnerAddress` | Old owner address |
| `newOwnerAddress` | New owner address |

``` solidity
event ownerChanged(address oldOwnerAddress, address newOwnerAddress);
```

#### metadataChanged

Emitted when NFT metadata is changed.

``` solidity
event metadataChanged();
```

#### printCreated

Emitted when NFT copy is printed.

| Parameter | Description |
|-----------|-------------|
| `printID`      | ID of the print |
| `printAddress` | Address of the print |

``` solidity
event printCreated(uint256 printID, address printAddress);
```

## Collection
### Methods

#### getInfo
#### callInfo

Returns collection information

| Parameter | Description |
|-----------|-------------|
| `includeMetadata`  | If metadata should be included |
| `includeTokenCode` | If token code should be included |

Return values:

| Parameter | Description |
|-----------|-------------|
| `nonce`                          | Random nonce to have random collection address |
| `tokenCode`                      | TvmCell of the token code |
| `tokensIssued`                   | Number of tokens this collection created |
| `ownerAddress`                   | Owner address |
| `creatorAddress`                 | Creator address |
| `metadataContents`               | Collection metadata; it has the same format as NFT metadata but keeps collection cover and information |
| `tokenPrimarySaleHappened`       | Default value for `tokenPrimarySaleHappened` param when minting NFT (see `ILiquidNFT.sol` for details) |
| `tokenMetadataIsMutable`         | Default value for `tokenMetadataIsMutable` param when minting NFT (see `ILiquidNFT.sol` for details) |
| `tokenMasterEditionMaxSupply`    | Default value for `tokenMasterEditionMaxSupply` param when minting NFT (see `ILiquidNFT.sol` for details) |
| `tokenMasterEditionPrintLocked`  | Default value for `tokenMasterEditionPrintLocked` param when minting NFT (see `ILiquidNFT.sol` for details) |
| `tokenCreatorsPercent`           | Default value for `tokenCreatorsPercent` param when minting NFT (see `ILiquidNFT.sol` for details) |
| `tokenCreatorsShares`            | Default value for `tokenCreatorsShares` param when minting NFT (see `ILiquidNFT.sol` for details) |

``` solidity
struct CreatorShare
{
    address creatorAddress; // 
    uint8   creatorShare;   // 100 = 1% share
}

function getInfo(bool includeMetadata, bool includeTokenCode) external view returns(
    uint256        nonce,
    TvmCell        tokenCode,
    uint256        tokensIssued,
    address        ownerAddress,
    address        creatorAddress,
    string         metadataContents,
    bool           tokenPrimarySaleHappened,
    bool           tokenMetadataIsMutable,
    uint256        tokenMasterEditionMaxSupply,
    bool           tokenMasterEditionPrintLocked,
    uint16         tokenCreatorsPercent,
    CreatorShare[] tokenCreatorsShares);

function callInfo(bool includeMetadata, bool includeTokenCode) external view responsible returns(
    uint256        nonce,
    TvmCell        tokenCode,
    uint256        tokensIssued,
    address        ownerAddress,
    address        creatorAddress,
    string         metadataContents,
    bool           tokenPrimarySaleHappened,
    bool           tokenMetadataIsMutable,
    uint256        tokenMasterEditionMaxSupply,
    bool           tokenMasterEditionPrintLocked,
    uint16         tokenCreatorsPercent,
    CreatorShare[] tokenCreatorsShares);
```

#### setOwner

Changes Collection owner.

| Parameter | Description |
|-----------|-------------|
| `ownerAddress` | New owner address |

``` solidity
function setOwner(address ownerAddress) external;
```

#### createNFT

Creates new NFT.

| Parameter | Description |
|-----------|-------------|
| `ownerAddress`             | New owner address |
| `creatorAddress`           | Creator address |
| `metadataContents`         | Metadata in JSON format (see `ILiquidNFT.sol`) |
| `metadataAuthorityAddress` | Metadata authority that can update metadata if needed |

``` solidity
function createNFT(
    address ownerAddress,
    address creatorAddress,
    string  metadataContents,
    address metadataAuthorityAddress) external returns (address tokenAddress);
```

#### createNFTExtended

Creates new NFT, extended version with all parameters.

| Parameter | Description |
|-----------|-------------|
| `ownerAddress`             | New owner address |
| `creatorAddress`           | Creator address |
| `primarySaleHappened`      | If 100% of the first sale should be distributed between the creators list |
| `metadataContents`         | Metadata in JSON format (see `ILiquidNFT.sol`) |
| `metadataIsMutable`        | If metadata can be changed by authority |
| `metadataAuthorityAddress` | Metadata authority that can update metadata if needed |
| `masterEditionMaxSupply`   | >0 if token should be printable |
| `masterEditionPrintLocked` | If printing is locked for this token |
| `creatorsPercent`          | Secondary market sale percent that creators receive after each trade |
| `creatorsShares`           | List of creators with their shares |

``` solidity
struct CreatorShare
{
    address creatorAddress; // 
    uint8   creatorShare;   // 1 = 1% share
}

function createNFTExtended(
    address        ownerAddress,
    address        creatorAddress,
    bool           primarySaleHappened,
    string         metadataContents,
    bool           metadataIsMutable,
    address        metadataAuthorityAddress,
    uint256        masterEditionMaxSupply,
    bool           masterEditionPrintLocked,
    uint16         creatorsPercent,
    CreatorShare[] creatorsShares) external returns (address tokenAddress);
```

### Events

#### nftMinted

Minted new NFT.

| Parameter | Description |
|-----------|-------------|
| `id`         | ID of the new NFT |
| `nftAddress` | Address of a new NFT |

``` solidity
event nftMinted(uint256 id, address nftAddress);
```

# Distributor 
## Methods

### getInfo

Gets Distributor information.

| Parameter | Description |
|-----------|-------------|
| `includeTokens`    | If token metadata list should be included |
| `includeWhitelist` | If token whitelist should be included |

``` js
function getInfo(bool includeTokens, bool includeWhitelist) external view returns(
    uint256   nonce,
    address   creatorAddress,
    address   ownerAddress,
    uint256   ownerPubkey,
    address   treasuryAddress,
    address   collectionAddress,
    uint32    saleStartDate,
    uint32    presaleStartDate,
    uint128   price,
    uint256   mintedAmount,
    string[]  tokens,
    uint256   tokensAmount,
    bool      tokensLocked,
    mapping(address => uint32) 
              whitelist,
    uint256   whitelistCount,
    uint32    whitelistBuyLimit);
```

### change

Changes Distributor parameters.

| Parameter | Description |
|-----------|-------------|
| `saleStartDate`    | Sale start date |
| `presaleStartDate` | Presale start date |
| `price`            | New price in nanoevers |

``` js
function change(uint32 saleStartDate, uint32 presaleStartDate, uint128 price) external;
```

### mint

External function to mint an NFT for the given price (presale/sale start dates are respected).

``` js
function mint() external;
```

### mintInternal

Internal function (owner only) to mint an NFT.

| Parameter | Description |
|-----------|-------------|
| `targetOwnerAddress`    | Desired owner of the minted NFT |

``` js
function mintInternal(address targetOwnerAddress) external;
```

### deleteWhitelist

Completely deletes current whitelist.

``` js
function deleteWhitelist() external;
```

### deleteFromWhitelist

Deletes specified entries from whitelist.

| Parameter | Description |
|-----------|-------------|
| `targetAddresses`       | List of addresses to delete |

``` js
function deleteFromWhitelist(address[] targetAddresses) external;
```

### addToWhitelist

Adds specified entries to whitelist.

| Parameter | Description |
|-----------|-------------|
| `targetAddresses`       | List of addresses to add |

``` js
function addToWhitelist(address[] targetAddresses) external;
```

### deleteTokens

Completely deletes current tokens metadata list.

``` js
function deleteTokens() external;
```

### setToken

Sets specified token metadata (token should already be added to the list).

| Parameter | Description |
|-----------|-------------|
| `index`    | Token index to change |
| `metadata` | New token metadata |

``` js
function setToken(uint256 index, string metadata) external;
```

### addTokens

Adds specified entries to token metadata list.

| Parameter | Description |
|-----------|-------------|
| `metadatas`    | List of metadatas to add |

``` js
function addTokens(string[] metadatas) external;
```

### lockTokens

Locks token list, it won't be able to be changed anymore. 
Mint is available only after locking.

``` js
function lockTokens() external;
```

## Implementation

Interfaces are in `interfaces` folder.

`Liquid contracts` `Collection`, `Token` and `Distributor` implementations are in `contracts` folder.

## History

TODO

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).