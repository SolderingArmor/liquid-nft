pragma ton-solidity >=0.55.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/IBase.sol";
import "../interfaces/IBasicToken.sol";

//================================================================================
//
contract BasicToken is IBasicToken, IBase
{
    //========================================
    // Error codes
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER      = 100;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_AUTHORITY  = 101;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_COLLECTION = 102;
    uint constant ERROR_MESSAGE_OWNER_CAN_NOT_BE_ZERO       = 103;

    //========================================
    // Variables
    address static _collectionAddress; //
    uint256 static _tokenID;           //
    // Addresses
    address        _ownerAddress;      //
    address        _authorityAddress;  // 
    // Metadata
    string         _metadata;          //

    //========================================
    // Events

    //========================================
    // Modifiers
    modifier onlyCollection {    require(_checkSenderAddress(_collectionAddress), ERROR_MESSAGE_SENDER_IS_NOT_MY_COLLECTION);    _;    }
    modifier onlyOwner      {    require(_checkSenderAddress(_ownerAddress),      ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);         _;    }
    modifier onlyAuthority  {    require(_checkSenderAddress(_authorityAddress),  ERROR_MESSAGE_SENDER_IS_NOT_MY_AUTHORITY);     _;    }

    //========================================
    // Getters
    function getBasicInfo(bool includeMetadata) external view responsible override reserve returns (
        address collectionAddress,
        uint256 tokenID,
        address ownerAddress,
        address authorityAddress,
        string  metadata)
    {
        return {value: 0, flag: 128}(
            _collectionAddress,
            _tokenID,
            _ownerAddress,
            _authorityAddress,
            includeMetadata ? _metadata : "{}");
    }

    //========================================
    //
    constructor(address ownerAddress,
                address authorityAddress,
                address initiatorAddress,
                string  metadata) public onlyCollection reserve returnChangeTo(initiatorAddress)
    {
        _ownerAddress     = ownerAddress;
        _authorityAddress = authorityAddress;
        _metadata         = metadata;
    }
    
    //========================================
    //    
    function setOwner(address ownerAddress) external override onlyAuthority reserve returnChange
    {
        emit ownerChanged    (_ownerAddress,     ownerAddress);
        emit authorityChanged(_authorityAddress, ownerAddress);

        _ownerAddress     = ownerAddress; //
        _authorityAddress = ownerAddress; // Changing Owner always resets Authority.
    }
    
    //========================================
    //    
    function setAuthority(address authorityAddress, TvmCell payload) external override onlyAuthority reserve
    {
        emit authorityChanged(_authorityAddress, authorityAddress);

        IBasicTokenSetAuthorityCallback(authorityAddress).onSetAuthorityCallback{value: 0, flag: 128, bounce: true}(
            _collectionAddress,
            _tokenID,
            _ownerAddress,
            _authorityAddress,
            payload);
        
        _authorityAddress = authorityAddress;
    }

    //========================================
    //
    function destroy() external override onlyAuthority
    {
        selfdestruct(_ownerAddress);
    }
    
    //========================================
    //
    onBounce(TvmSlice slice) external reserve returnChangeTo(_ownerAddress)
    {
        uint32 functionId = slice.decode(uint32);
        if (functionId == tvm.functionId(IBasicTokenSetAuthorityCallback.onSetAuthorityCallback)) 
        {
            emit authorityChanged(_authorityAddress, _ownerAddress);
            _authorityAddress = _ownerAddress; // Reset Authority
        }
    }
}

//================================================================================
//
