pragma ton-solidity >=0.55.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
// Metadata JSON format:
// type - Human readable type of metadata. Based on the type any external (off-chain) service will know how to parse it. Example:
//     "Some Token Type" - ...;
//
// EXAMPLE:
//{
//    "type": "Some Token Type"
//}
//================================================================================
//
interface ILiquidTokenBase
{
    //========================================
    // Events
    event ownerChanged(address from, address to);
    event destroyed(address ownerAddress);

    //========================================
    /// @notice Returns Token information;
    ///
    /// @param includeMetadata - If metadata should be included (empty string otherwise);
    ///
    /// Return values:
    ///     collectionAddress - Token collection address;
    ///     tokenID           - Token ID;
    ///     ownerAddress      - Token owner;
    ///     creatorAddress    - Token creator;
    ///     metadata          - Token metadata in JSON format;
    //
    function getBasicInfo(bool includeMetadata) external view returns (
        address collectionAddress,
        uint256 tokenID,
        address ownerAddress,
        address creatorAddress,
        string  metadata);

    function callBasicInfo(bool includeMetadata) external responsible view returns (
        address collectionAddress,
        uint256 tokenID,
        address ownerAddress,
        address creatorAddress,
        string  metadata);

    //========================================
    /// @notice Changes Token owner;
    ///
    /// @param ownerAddress - New owner address;
    //
    function setOwner(address ownerAddress) external;
    
    //========================================
    /// @notice Destroys Token;
    ///         WARNING! This can not be undone;
    //
    function destroy() external;
}

//================================================================================
//
