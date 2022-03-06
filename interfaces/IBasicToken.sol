pragma ton-solidity >=0.55.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
// Metadata JSON format:
// schema - Human readable type/substandard of metadata. Based on the type any external (off-chain) service will know how to parse it. Example:
//     "Some Token Type" - ...;
//
// EXAMPLE:
//{
//    "schema": "Some Token Type"
//}
//================================================================================
//
interface IBasicTokenSetAuthorityCallback
{
    function onSetAuthorityCallback(
        address collectionAddress,
        uint256 tokenID,
        address ownerAddress,
        address initiatorAddress,
        TvmCell payload) external;
}

//================================================================================
//
interface IBasicToken
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
    ///     ownerAddress      - Token Owner;
    ///     authorityAddress  - Token Authority; used as a temporary manager for auctions, staking, farming, etc.
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
    ///         Restrictions: only Aythority can call this function.
    ///
    /// @param ownerAddress - New Owner address;
    //
    function setOwner(address ownerAddress) external;

    //========================================
    /// @notice Changes Token Authority and calls `onSetAuthorityCallback` with 
    ///         new Authority as message receiver. Bounce should always be true,
    ///         if this Callback bounces we need to reset authority value to `ownerAddress`.
    ///         Restrictions: only Aythority can call this function.
    ///
    /// @param authorityAddress - New Authority address;
    //
    function setAuthority(address authorityAddress, TvmCell payload) external;
    
    //========================================
    /// @notice Destroys Token;
    ///         WARNING! This can not be undone;
    //
    function destroy() external;
}

//================================================================================
//
