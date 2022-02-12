pragma ton-solidity >=0.52.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../contracts/LiquidNFT.sol";

//================================================================================
//
interface ILiquidNFTCollection
{
    //========================================
    /// @notice Creates new NFT;
    ///
    /// @param ownerAddress             - New owner address;
    /// @param creatorAddress           - Creator   address;
    /// @param metadataContents         - Metadata in JSON format (see `ILiquidNFT.sol`);
    /// @param metadataAuthorityAddress - Metadata authority that can update metadata if needed;
    //
    function createNFT(address ownerAddress,
                       address creatorAddress,
                       string  metadataContents,
                       address metadataAuthorityAddress) external returns (address tokenAddress);
    
    //========================================
    /// @notice Creates new NFT, extended version with all parameters;
    ///
    /// @param ownerAddress             - New owner address;
    /// @param creatorAddress           - Creator   address;
    /// @param primarySaleHappened      - If 100% of the first sale should be distributed between the creators list;
    /// @param metadataContents         - Metadata in JSON format (see `ILiquidNFT.sol`);
    /// @param metadataIsMutable        - If metadata can be changed by authority;
    /// @param metadataAuthorityAddress - Metadata authority that can update metadata if needed;
    /// @param masterEditionMaxSupply   - >0 if token should be printable;
    /// @param masterEditionPrintLocked - If printing is locked for this token;
    /// @param creatorsPercent          - Secondary market sale percent that creators receive after each trade;
    /// @param creatorsShares           - List of creators with their shares;
    //
    function createNFTExtended(address        ownerAddress,
                               address        creatorAddress,
                               bool           primarySaleHappened,
                               string         metadataContents,
                               bool           metadataIsMutable,
                               address        metadataAuthorityAddress,
                               uint256        masterEditionMaxSupply,
                               bool           masterEditionPrintLocked,
                               uint16         creatorsPercent,
                               CreatorShare[] creatorsShares) external returns (address tokenAddress);

    //========================================
    /// @notice Changes collection owner;
    ///
    /// @param ownerAddress - New owner address;
    //
    function setOwner(address ownerAddress) external;
    
    //========================================
    /// @notice Returns collection information;
    ///
    /// @param includeMetadata  - If metadata   should be included;
    /// @param includeTokenCode - If token code should be included;
    ///
    /// Return values:
    ///     nonce                         - Random nonce to have random collection address;
    ///     tokenCode                     - TvmCell of the token code;
    ///     tokensIssued                  - Number of tokens this collection created;
    ///     ownerAddress                  - Owner   address;
    ///     creatorAddress                - Creator address;
    ///     metadataContents              - Collection metadata; it has the same format as NFT metadata but keeps collection cover and information;
    ///     tokenPrimarySaleHappened      - Default value for `tokenPrimarySaleHappened`      param when minting NFT (see `ILiquidNFT.sol` for details);
    ///     tokenMetadataIsMutable        - Default value for `tokenMetadataIsMutable`        param when minting NFT (see `ILiquidNFT.sol` for details);
    ///     tokenMasterEditionMaxSupply   - Default value for `tokenMasterEditionMaxSupply`   param when minting NFT (see `ILiquidNFT.sol` for details);
    ///     tokenMasterEditionPrintLocked - Default value for `tokenMasterEditionPrintLocked` param when minting NFT (see `ILiquidNFT.sol` for details);
    ///     tokenCreatorsPercent          - Default value for `tokenCreatorsPercent`          param when minting NFT (see `ILiquidNFT.sol` for details);
    ///     tokenCreatorsShares           - Default value for `tokenCreatorsShares`           param when minting NFT (see `ILiquidNFT.sol` for details);
    //
    function getInfo(bool includeMetadata, bool includeTokenCode) external view 
                                                                  returns(uint256        nonce,
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

    function callInfo(bool includeMetadata, bool includeTokenCode) external view responsible 
                                                                   returns(uint256        nonce,
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
}
