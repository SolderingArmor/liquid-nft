pragma ton-solidity >=0.52.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/ILiquidCollectionBase.sol";
import "../interfaces/ILiquidToken.sol";

//================================================================================
//
interface ILiquidCollection is ILiquidCollectionBase
{
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
    ///     ownerAddress                  - Owner address;
    ///     metadata                      - Collection metadata; it has the same format as NFT metadata but keeps collection cover and information;
    ///     tokenCreatorAddress           - Default value for `creatorAddress`                param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenPrimarySaleHappened      - Default value for `tokenPrimarySaleHappened`      param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenMetadataIsMutable        - Default value for `tokenMetadataIsMutable`        param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenMasterEditionMaxSupply   - Default value for `tokenMasterEditionMaxSupply`   param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenMasterEditionPrintLocked - Default value for `tokenMasterEditionPrintLocked` param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenCreatorsPercent          - Default value for `tokenCreatorsPercent`          param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenCreatorsShares           - Default value for `tokenCreatorsShares`           param when minting Token (see `ILiquidToken.sol` for details);
    //
    function getInfo(bool includeMetadata, bool includeTokenCode) external view returns(
        uint256        nonce,
        TvmCell        tokenCode,
        uint256        tokensIssued,
        address        ownerAddress,
        string         metadata,
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
        string         metadata,
        bool           tokenPrimarySaleHappened,
        bool           tokenMetadataIsMutable,
        uint256        tokenMasterEditionMaxSupply,
        bool           tokenMasterEditionPrintLocked,
        uint16         tokenCreatorsPercent,
        CreatorShare[] tokenCreatorsShares);

    //========================================
    /// @notice Creates new NFT;
    ///
    /// @param ownerAddress             - New owner address;
    /// @param creatorAddress           - Creator   address;
    /// @param metadata                 - Metadata in JSON format (see `ILiquidNFT.sol`);
    /// @param metadataAuthorityAddress - Metadata authority that can update metadata if needed;
    //
    function createToken(
        address ownerAddress,
        address creatorAddress,
        string  metadata,
        address metadataAuthorityAddress) external returns (address tokenAddress);
    
    //========================================
    /// @notice Creates new NFT, extended version with all parameters;
    ///
    /// @param ownerAddress             - New owner address;
    /// @param creatorAddress           - Creator   address;
    /// @param primarySaleHappened      - If 100% of the first sale should be distributed between the creators list;
    /// @param metadata                 - Metadata in JSON format (see `ILiquidNFT.sol`);
    /// @param metadataIsMutable        - If metadata can be changed by authority;
    /// @param metadataAuthorityAddress - Metadata authority that can update metadata if needed;
    /// @param masterEditionMaxSupply   - >0 if token should be printable;
    /// @param masterEditionPrintLocked - If printing is locked for this token;
    /// @param creatorsPercent          - Secondary market sale percent that creators receive after each trade;
    /// @param creatorsShares           - List of creators with their shares;
    //
    function createTokenExtended(
        address        ownerAddress,
        address        creatorAddress,
        bool           primarySaleHappened,
        string         metadata,
        bool           metadataIsMutable,
        address        metadataAuthorityAddress,
        uint256        masterEditionMaxSupply,
        bool           masterEditionPrintLocked,
        uint16         creatorsPercent,
        CreatorShare[] creatorsShares) external returns (address tokenAddress);
}

//================================================================================
//
