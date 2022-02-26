pragma ton-solidity >=0.52.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/IBase.sol";
import "../interfaces/ILiquidToken.sol";

//================================================================================
//
contract LiquidToken is ILiquidToken, IBase
{
    //========================================
    // Error codes
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER              = 100;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_AUTHORITY          = 101;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_COLLECTION         = 102;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_METADATA_AUTHORITY = 103;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_MASTER             = 104;
    uint constant ERROR_MESSAGE_OWNER_CAN_NOT_BE_ZERO               = 105;
    uint constant ERROR_MESSAGE_METADATA_IS_LOCKED                  = 200;
    uint constant ERROR_MESSAGE_PRINT_IS_LOCKED                     = 201;
    uint constant ERROR_MESSAGE_PRINT_SUPPLY_EXCEEDED               = 202;
    uint constant ERROR_MESSAGE_CAN_NOT_REPRINT                     = 203;
    uint constant ERROR_MESSAGE_PRIMARY_SALE_HAPPENED               = 204;
    uint constant ERROR_MESSAGE_TOO_MANY_CREATORS                   = 205;
    uint constant ERROR_MESSAGE_SHARE_NOT_EQUAL_100                 = 206;

    //========================================
    // Variables
    address static _collectionAddress;        //
    uint256 static _tokenID;                  //
    // Addresses
    address        _ownerAddress;             //
    address        _authorityAddress;         // 
    // Metadata
    bool           _primarySaleHappened;      //
    string         _metadata;                 //
    bool           _metadataIsMutable;        //
    address        _metadataAuthorityAddress; //
    // Edition
    uint256        _masterEditionSupply;      //
    uint256        _masterEditionMaxSupply;   // Unlimited when 0;
    bool           _masterEditionPrintLocked; //
    uint256 static _editionNumber;            // Always 0 for regular NFTs, >0 for printed editions;
    // Money
    uint16         _creatorsPercent;          // 1% = 100, 100% = 10000;
    CreatorShare[] _creatorsShares;           //         

    //========================================
    // Events

    //========================================
    // Modifiers
    function senderIsCollection() internal view inline returns (bool) {    return _checkSenderAddress(_collectionAddress);    }
    function senderIsOwner()      internal view inline returns (bool) {    return _checkSenderAddress(_ownerAddress);         }
    function senderIsAuthority()  internal view inline returns (bool) {    return _checkSenderAddress(_authorityAddress);     }
    function senderIsMaster()     internal view inline returns (bool) {    (address master, ) = calculateFutureTokenAddress(_tokenID, 0);    return _checkSenderAddress(master);    }

    modifier onlyMaster             {    require(senderIsMaster(),                                ERROR_MESSAGE_SENDER_IS_NOT_MY_MASTER);                 _;    }
    modifier onlyCollection         {    require(_checkSenderAddress(_collectionAddress),         ERROR_MESSAGE_SENDER_IS_NOT_MY_COLLECTION);             _;    }
    modifier onlyOwner              {    require(senderIsOwner(),                                 ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);                  _;    }
    modifier onlyAuthority          {    require(senderIsAuthority(),                             ERROR_MESSAGE_SENDER_IS_NOT_MY_AUTHORITY);              _;    }
    modifier onlyMetadataAuthority  {    require(_checkSenderAddress(_metadataAuthorityAddress),  ERROR_MESSAGE_SENDER_IS_NOT_MY_METADATA_AUTHORITY);     _;    }

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
    function getInfo(bool includeMetadata) external responsible view override reserve returns (
        address        collectionAddress,
        uint256        tokenID,
        address        ownerAddress,
        address        authorityAddress,
        string         metadata,
        bool           primarySaleHappened,
        bool           metadataIsMutable,
        address        metadataAuthorityAddress,
        uint256        masterEditionSupply,
        uint256        masterEditionMaxSupply,
        bool           masterEditionPrintLocked,
        uint256        editionNumber,
        uint16         creatorsPercent,
        CreatorShare[] creatorsShares)
    {
        return {value: 0, flag: 128}(
            _collectionAddress,
            _tokenID,
            _ownerAddress,
            _authorityAddress,
            (includeMetadata ? _metadata : "{}"),
            _primarySaleHappened,
            _metadataIsMutable,
            _metadataAuthorityAddress,
            _masterEditionSupply,
            _masterEditionMaxSupply,
            _masterEditionPrintLocked,
            _editionNumber,
            _creatorsPercent,
            _creatorsShares);
    }

    //========================================
    //
    function calculateFutureTokenAddress(uint256 tokenID, uint256 editionNumber) private inline view returns (address, TvmCell)
    {
        TvmCell stateInit = tvm.buildStateInit({
            contr: LiquidToken,
            varInit: {
                _collectionAddress: _collectionAddress,
                _tokenID:           tokenID,
                _editionNumber:     editionNumber
            },
            code: tvm.code()
        });

        return (address(tvm.hash(stateInit)), stateInit);
    }

    //========================================
    //
    constructor(address        ownerAddress,
                address        initiatorAddress,
                string         metadata,
                bool           primarySaleHappened,
                bool           metadataIsMutable,
                address        metadataAuthorityAddress,
                uint256        masterEditionMaxSupply,
                bool           masterEditionPrintLocked,
                uint16         creatorsPercent,
                CreatorShare[] creatorsShares) public reserve
    {
        // Checking who is printing or creating, it should be collection or master copy
        if(_editionNumber == 0)
        {
            require(senderIsCollection(), ERROR_MESSAGE_SENDER_IS_NOT_MY_COLLECTION);

            _masterEditionSupply      = 0;
            _masterEditionMaxSupply   = masterEditionMaxSupply;
            _masterEditionPrintLocked = masterEditionPrintLocked;
        }
        else
        {
            require(senderIsMaster(), ERROR_MESSAGE_SENDER_IS_NOT_MY_MASTER);
        
            // Printed versions can't reprint
            _masterEditionSupply      = 0;
            _masterEditionMaxSupply   = 0;
            _masterEditionPrintLocked = true;
        }

        require(creatorsShares.length <= 5, ERROR_MESSAGE_TOO_MANY_CREATORS);

        uint16 shareSum = 0;
        for(CreatorShare shareInfo : creatorsShares)
        {
            shareSum += shareInfo.creatorShare;
        }
        require(shareSum == 10000, ERROR_MESSAGE_SHARE_NOT_EQUAL_100);

        _ownerAddress             = ownerAddress;
        _authorityAddress         = addressZero;
        _metadata                 = metadata;
        _primarySaleHappened      = primarySaleHappened;
        _metadataIsMutable        = metadataIsMutable;
        _metadataAuthorityAddress = metadataAuthorityAddress;
        _creatorsPercent          = creatorsPercent;
        _creatorsShares           = creatorsShares;

        // Return the change
        initiatorAddress.transfer(0, true, 128);
    }
    
    //========================================
    //    
    function setOwner(address ownerAddress) external override reserve returnChange
    {
        // If Authority is set Owner can't change anything
        if(_authorityAddress != addressZero){    require(senderIsAuthority(), ERROR_MESSAGE_SENDER_IS_NOT_MY_AUTHORITY);    }
        else                                {    require(senderIsOwner(),     ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);        }
        
        if(_authorityAddress != addressZero)
        {
            emit authorityChanged(_authorityAddress, addressZero);
            _authorityAddress = addressZero;  // Changing Owner always resets Authority.
        }

        emit ownerChanged(_ownerAddress, ownerAddress);
        _ownerAddress = ownerAddress; //
        _primarySaleHappened = true;  // Any owner change automatically means flipping primary sale, 
                                      // because auctioning the Token won't change the owner (_authorityAddress is changed instead).
    }
    
    //========================================
    //    
    function setAuthority(address authorityAddress, TvmCell payload) external override reserve
    {
        // If Authority is set Owner can't change anything
        if(_authorityAddress != addressZero){    require(senderIsAuthority(), ERROR_MESSAGE_SENDER_IS_NOT_MY_AUTHORITY);    }
        else                                {    require(senderIsOwner(),     ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);        }
        
        emit authorityChanged(_authorityAddress, authorityAddress);
        _authorityAddress = authorityAddress;

        ILiquidTokenSetAuthorityCallback(authorityAddress).onSetAuthorityCallback{value: 0, flag: 128, bounce: true}(
            _collectionAddress,
            _tokenID,
            _ownerAddress,
            payload);
    }

    //========================================
    //    
    function setMetadata(string metadata) external override onlyMetadataAuthority reserve returnChange
    {
        require(_metadataIsMutable, ERROR_MESSAGE_METADATA_IS_LOCKED);
        emit metadataChanged();
        _metadata = metadata;
    }

    //========================================
    //    
    function lockMetadata() external override onlyMetadataAuthority reserve returnChange
    {
        require(_metadataIsMutable, ERROR_MESSAGE_METADATA_IS_LOCKED);
        _metadataIsMutable = false;
    }

    //========================================
    //    
    function printCopy(address targetOwnerAddress) external override onlyOwner reserve
    {
        // TODO: require enough funds
        
        require(_editionNumber == 0,                            ERROR_MESSAGE_CAN_NOT_REPRINT      );
        require(!_masterEditionPrintLocked,                     ERROR_MESSAGE_PRINT_IS_LOCKED      );
        require(_masterEditionMaxSupply > 0 && 
                _masterEditionMaxSupply > _masterEditionSupply, ERROR_MESSAGE_PRINT_SUPPLY_EXCEEDED);
        
        _masterEditionSupply += 1;
        (address addr, TvmCell stateInit) = calculateFutureTokenAddress(_tokenID, _masterEditionSupply);
        emit printCreated(_masterEditionSupply, addr);

        new LiquidToken{value: 0, flag: 128, stateInit: stateInit}(
            targetOwnerAddress,
            _ownerAddress,
            _metadata,
            _primarySaleHappened,
            _metadataIsMutable,
            _metadataAuthorityAddress,
            0,
            true,
            _creatorsPercent,
            _creatorsShares);
    }

    //========================================
    //
    function lockPrint() external override onlyOwner reserve returnChange
    {
        require(!_masterEditionPrintLocked, ERROR_MESSAGE_PRINT_IS_LOCKED);
        _masterEditionPrintLocked = true;
    }

    //========================================
    //
    function destroy() external override onlyOwner
    {
        selfdestruct(_ownerAddress);
    }
    
    //========================================
    //
    onBounce(TvmSlice slice) external reserve
    {
        uint32 functionId = slice.decode(uint32);
        if (functionId == tvm.functionId(ILiquidTokenSetAuthorityCallback.onSetAuthorityCallback)) 
        {
            emit authorityChanged(_authorityAddress, addressZero);
            _authorityAddress = addressZero; // Reset Authority

            _ownerAddress.transfer(0, true, 128);
        }
    }
}

//================================================================================
//
