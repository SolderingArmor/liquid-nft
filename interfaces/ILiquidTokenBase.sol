pragma ton-solidity >=0.55.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
// Metadata JSON format:
// schema_type - Human readable type/substandard of metadata. Based on the type any external (off-chain) service will know how to parse it. Example:
//     "Some Token Type" - ...;
//
// EXAMPLE:
//{
//    "schema_type": "Some Token Type"
//}
//================================================================================
//
interface ILiquidTokenSetAuthorityCallback
{
        function onSetAuthorityCallback(
            address collectionAddress,
            uint256 tokenID,
            address ownerAddress,
            address authorityAddress) external;
}

//================================================================================
//
// TODO: add authority and set authority callback
// set manager callback bounce is important
// add events for authority
// can remove creator from standard
// field TYPE in json - rename
// reset authority on bounce callback
interface ILiquidTokenBase
{
    //========================================
    // Events
    event ownerChanged    (address from, address to);
    event authorityChanged(address from, address to);
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
    ///     authorityAddress  - Token Authority; when set it can change the Owner and itself, used as a temporary manager for auctions, staking, farming, etc.
    ///     metadata          - Token metadata in JSON format;
    //
    function getBasicInfo(bool includeMetadata) external view responsible returns (
        address collectionAddress,
        uint256 tokenID,
        address ownerAddress,
        address authorityAddress,
        string  metadata);

    //========================================
    /// @notice Changes Token Owner;
    ///
    /// @param ownerAddress - New Owner address;
    //
    function setOwner(address ownerAddress) external;

    //========================================
    /// @notice Changes Token Authority and calls `onSetAuthorityCallback` with 
    ///         new Authority as message receiver. Bounce should always be true,
    ///         if this Callback bounces we need to reset authority value to `addressZero`.
    ///
    /// @param authorityAddress - New Authority address;
    //
    function setAuthority(address authorityAddress) external;
    
    //========================================
    /// @notice Destroys Token;
    ///         WARNING! This can not be undone;
    //
    function destroy() external;
}

//================================================================================
//
