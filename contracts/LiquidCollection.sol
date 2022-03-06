pragma ton-solidity >=0.52.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/ILiquidCollection.sol";
import "../interfaces/IBase.sol";
import "../contracts/LiquidToken.sol";

//================================================================================
// 
contract LiquidCollection is IBase, ILiquidCollection
{
    //========================================
    // Error codes
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER = 100;
    uint constant ERROR_MESSAGE_OWNER_CAN_NOT_BE_ZERO  = 104;
    uint constant ERROR_MESSAGE_TOO_MANY_CREATORS      = 205;
    uint constant ERROR_MESSAGE_SHARE_NOT_EQUAL_100    = 206;
    uint constant ERROR_VALUE_NOT_ENOUGH_TO_MINT       = 207;

    //========================================
    // Variables
    uint256 static _nonce;                         // Random number to randomize collection address;
    TvmCell static _tokenCode;                     //
    uint256        _tokensIssued;                  //
    address        _ownerAddress;                  //
    // Metadata
    string         _metadata;                      // Collection metadata, for the collection cover and info;
    // Token configuration
    bool           _tokenPrimarySaleHappened;      // Default value when minting, usually true for degens;
    bool           _tokenMetadataLocked;        // 
    uint256        _tokenMasterEditionMaxSupply;   // Unlimited when 0;
    bool           _tokenMasterEditionPrintLocked; //
    uint16         _tokenCreatorsPercent;          // 1% = 100, 100% = 10000;
    CreatorShare[] _tokenCreatorsShares;           //

    //========================================
    // Modifiers
    modifier onlyOwner {    require(_checkSenderAddress(_ownerAddress), ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);    _;    }

    //========================================
    // Getters
    function getBasicInfo(bool includeMetadata, bool includeTokenCode) external view responsible override returns(
        uint256 nonce,
        TvmCell tokenCode,
        uint256 tokensIssued,
        address ownerAddress,
        string  metadata)
    {
        TvmCell empty;        
        return {value: 0, flag: 128}(
            _nonce,
            (includeTokenCode ? _tokenCode : empty),
            _tokensIssued,
            _ownerAddress,
            includeMetadata ? _metadata : "{}");
    }

    //========================================
    //
    function getInfo(bool includeMetadata, bool includeTokenCode) external view override responsible reserve returns(
        uint256        nonce,
        TvmCell        tokenCode,
        uint256        tokensIssued,
        address        ownerAddress,
        string         metadata,
        bool           tokenPrimarySaleHappened,
        bool           tokenMetadataLocked,
        uint256        tokenMasterEditionMaxSupply,
        bool           tokenMasterEditionPrintLocked,
        uint16         tokenCreatorsPercent,
        CreatorShare[] tokenCreatorsShares)
    {
        TvmCell empty;        
        return {value: 0, flag: 128}(
            _nonce,
            (includeTokenCode ? _tokenCode : empty),
            _tokensIssued,
            _ownerAddress,
            (includeMetadata ? _metadata : "{}"),
            _tokenPrimarySaleHappened,
            _tokenMetadataLocked,
            _tokenMasterEditionMaxSupply,
            _tokenMasterEditionPrintLocked,
            _tokenCreatorsPercent,
            _tokenCreatorsShares);
    }

    //========================================
    // 
    function calculateFutureTokenAddress(uint256 tokenID, uint256 printID) private inline view returns (address, TvmCell)
    {
        TvmCell stateInit = tvm.buildStateInit({
            contr: LiquidToken,
            varInit: {
                _collectionAddress: address(this), //
                _tokenID:           tokenID,       //
                _printID:           printID        // Collection creates only masters, not prints
            },
            code: _tokenCode
        });

        return (address(tvm.hash(stateInit)), stateInit);
    }

    //========================================
    //
    function getTokenAddress(uint256 targetTokenID) external view responsible override returns (uint256 tokenID, address tokenAddress)
    {
        (address addr, ) = calculateFutureTokenAddress(targetTokenID, 0);
        return {value: 0, flag: 128}(targetTokenID, addr);
    }

    //========================================
    //
    function getPrintAddress(uint256 targetTokenID, uint256 targetPrintID) external view responsible returns (uint256 tokenID, uint256 printID, address tokenAddress)
    {
        (address addr, ) = calculateFutureTokenAddress(targetTokenID, targetPrintID);
        return {value: 0, flag: 128}(targetTokenID, targetPrintID, addr);
    }

    //========================================
    //
    constructor(address        ownerAddress, 
                address        initiatorAddress, 
                string         metadata, 
                bool           tokenPrimarySaleHappened,
                bool           tokenMetadataLocked,
                uint256        tokenMasterEditionMaxSupply,
                bool           tokenMasterEditionPrintLocked,
                uint16         tokenCreatorsPercent,
                CreatorShare[] tokenCreatorsShares) public reserve returnChangeTo(initiatorAddress)
    {
        if(msg.isExternal){    tvm.accept();    }
        require(ownerAddress != addressZero,      ERROR_MESSAGE_OWNER_CAN_NOT_BE_ZERO);
        require(tokenCreatorsShares.length <= 5,  ERROR_MESSAGE_TOO_MANY_CREATORS    );

        uint16 shareSum = 0;
        for(CreatorShare shareInfo : tokenCreatorsShares)
        {
            shareSum += shareInfo.creatorShare;
        }
        require(shareSum == 10000, ERROR_MESSAGE_SHARE_NOT_EQUAL_100);

        // Collection configuration
        _tokensIssued = 0;
        _ownerAddress = ownerAddress;
        _metadata     = metadata;

        // Token configuration
        _tokenPrimarySaleHappened      = tokenPrimarySaleHappened;
        _tokenMetadataLocked           = tokenMetadataLocked;
        _tokenMasterEditionMaxSupply   = tokenMasterEditionMaxSupply;
        _tokenMasterEditionPrintLocked = tokenMasterEditionPrintLocked;
        _tokenCreatorsPercent          = tokenCreatorsPercent;
        _tokenCreatorsShares           = tokenCreatorsShares;
    }

    //========================================
    //
    function _createToken(
        address        ownerAddress,
        address        initiatorAddress,
        string         metadata,
        bool           metadataLocked,
        address        metadataAuthorityAddress,
        bool           primarySaleHappened,
        uint256        printMaxSupply,
        bool           printLocked,
        uint16         creatorsPercent,
        CreatorShare[] creatorsShares) internal returns (address)
    {
        require(msg.value >= gasToValue(400000, address(this).wid), ERROR_VALUE_NOT_ENOUGH_TO_MINT); // TODO: adjust value

        (address addr, TvmCell stateInit) = calculateFutureTokenAddress(_tokensIssued, 0);
        emit mint(_tokensIssued, addr, ownerAddress, initiatorAddress);

        new LiquidToken{value: 0, flag: 128, stateInit: stateInit}(
            ownerAddress,
            initiatorAddress,
            metadata,
            metadataLocked,
            metadataAuthorityAddress,
            primarySaleHappened,
            printMaxSupply,
            printLocked,
            creatorsPercent,
            creatorsShares);

        _tokensIssued += 1;
        return addr;
    }

    //========================================
    //
    function createToken(
        address ownerAddress,
        address initiatorAddress,
        string  metadata,
        address metadataAuthorityAddress) external override onlyOwner reserve returns (address tokenAddress)
    {
       tokenAddress = _createToken(
            ownerAddress,
            initiatorAddress,
            metadata,
            _tokenMetadataLocked,
            metadataAuthorityAddress,
            _tokenPrimarySaleHappened,
            _tokenMasterEditionMaxSupply,
            _tokenMasterEditionPrintLocked,
            _tokenCreatorsPercent,
            _tokenCreatorsShares);
    }

    //========================================
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
        CreatorShare[] creatorsShares) external override onlyOwner reserve returns (address tokenAddress)
    {
        tokenAddress = _createToken(
            ownerAddress,
            initiatorAddress,
            metadata,
            metadataLocked,
            metadataAuthorityAddress,
            primarySaleHappened,
            printMaxSupply,
            printLocked,
            creatorsPercent,
            creatorsShares);
    }

    //========================================
    //    
    function setOwner(address ownerAddress) external override onlyOwner reserve returnChange
    {
        emit ownerChanged(_ownerAddress, ownerAddress);
        _ownerAddress = ownerAddress;
    }
    
    //========================================
    //    
}

//================================================================================
//
