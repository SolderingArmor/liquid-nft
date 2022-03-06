pragma ton-solidity >=0.52.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/IBasicCollection.sol";
import "../interfaces/ILiquidToken.sol";

//================================================================================
//
interface ILiquidCollection is IBasicCollection
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
    ///     tokenMetadataLocked           - Default value for `tokenMetadataLocked`           param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenPrintMaxSupply           - Default value for `tokenPrintMaxSupply`           param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenpPrintLocked             - Default value for `tokenPrintLocked`              param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenCreatorsPercent          - Default value for `tokenCreatorsPercent`          param when minting Token (see `ILiquidToken.sol` for details);
    ///     tokenCreatorsShares           - Default value for `tokenCreatorsShares`           param when minting Token (see `ILiquidToken.sol` for details);
    //
    function getInfo(bool includeMetadata, bool includeTokenCode) external view responsible returns(
        uint256        nonce,
        TvmCell        tokenCode,
        uint256        tokensIssued,
        address        ownerAddress,
        string         metadata,
        bool           tokenPrimarySaleHappened,
        bool           tokenMetadataLocked,
        uint256        tokenPrintMaxSupply,
        bool           tokenpPrintLocked,
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
    /// @param initiatorAddress         - Transaction initiator address;
    /// @param metadata                 - Metadata in JSON format (see `ILiquidNFT.sol`);
    /// @param metadataLocked           - If metadata can be changed by authority;
    /// @param metadataAuthorityAddress - Metadata authority that can update metadata if needed;
    /// @param primarySaleHappened      - If 100% of the first sale should be distributed between the creators list;
    /// @param printMaxSupply           - >0 if token should be printable;
    /// @param printLocked              - If printing is locked for this token;
    /// @param creatorsPercent          - Secondary market sale percent that creators receive after each trade;
    /// @param creatorsShares           - List of creators with their shares;
    //
    function createTokenExtended(
        address        ownerAddress,
        address        initiatorAddress,
        string         metadata,
        bool           metadataLocked,
        address        metadataAuthorityAddress,
        bool           primarySaleHappened,
        uint256        printMaxSupply,
        bool           printLocked,
        uint16         creatorsPercent,
        CreatorShare[] creatorsShares) external returns (address tokenAddress);
}

//================================================================================
//
