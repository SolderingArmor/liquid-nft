pragma ton-solidity >=0.55.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
// Creating Tokens is not standardized because creation .
interface IBasicCollection
{
    //========================================
    // Events
    event mint(uint256 tokenID, address tokenAddress, address ownerAddress, address initiatorAddress);
    event ownerChanged(address from, address to);

    //========================================
    /// @notice Returns collection information;
    ///
    /// @param includeMetadata  - If metadata   should be included;
    /// @param includeTokenCode - If token code should be included;
    ///
    /// Return values:
    ///     nonce          - Random nonce to have random collection address;
    ///     tokenCode      - TvmCell of the token code;
    ///     tokensIssued   - Number of tokens this collection created;
    ///     ownerAddress   - Owner   address;
    ///     metadata       - Collection metadata; it has the same format as NFT metadata but keeps collection cover and information;
    //
    function getBasicInfo(bool includeMetadata, bool includeTokenCode) external view responsible returns(
        uint256 nonce,
        TvmCell tokenCode,
        uint256 tokensIssued,
        address ownerAddress,
        string  metadata);

    //========================================
    /// @notice Calculated desired Token address;
    ///
    /// @param targetTokenID - Token ID;
    //
    function getTokenAddress(uint256 targetTokenID) external view responsible returns (uint256 tokenID, address tokenAddress);

    //========================================
    /// @notice Changes Collection Owner;
    ///
    /// @param ownerAddress - New Owner address;
    //
    function setOwner(address ownerAddress) external;
}

//================================================================================
//
