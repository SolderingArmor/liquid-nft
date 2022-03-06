pragma ton-solidity >=0.52.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/IBasicCollection.sol";
import "../interfaces/IBase.sol";
import "../contracts/BasicToken.sol";

//================================================================================
// 
contract BasicCollection is IBase, IBasicCollection
{
    //========================================
    // Error codes
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER = 100;
    uint constant ERROR_MESSAGE_OWNER_CAN_NOT_BE_ZERO  = 103;
    uint constant ERROR_VALUE_NOT_ENOUGH_TO_MINT       = 200;

    //========================================
    // Variables
    uint256 static _nonce;        // Random number to randomize collection address;
    TvmCell static _tokenCode;    //
    uint256        _tokensIssued; //
    address        _ownerAddress; //
    // Metadata
    string         _metadata;     // Collection metadata, for the collection cover and info;

    //========================================
    // Modifiers
    modifier onlyOwner {    require(_checkSenderAddress(_ownerAddress), ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);    _;    }

    //========================================
    // Getters
    function getBasicInfo(bool includeMetadata, bool includeTokenCode) external view responsible override reserve returns(
        uint256 nonce,
        TvmCell tokenCode,
        uint256 tokensIssued,
        address ownerAddress,
        string  metadata)
    {
        TvmCell empty;        
        return {value: 0, flag: 128}(
            _nonce,
            includeTokenCode ? _tokenCode : empty,
            _tokensIssued,
            _ownerAddress,
            includeMetadata ? _metadata : "{}");
    }

    //========================================
    // 
    function calculateFutureTokenAddress(uint256 tokenID) private inline view returns (address, TvmCell)
    {
        TvmCell stateInit = tvm.buildStateInit({
            contr: BasicToken,
            varInit: {
                _collectionAddress: address(this), //
                _tokenID:           tokenID        //
            },
            code: _tokenCode
        });

        return (address(tvm.hash(stateInit)), stateInit);
    }

    //========================================
    //
    function getTokenAddress(uint256 targetTokenID) external view responsible override reserve returns (uint256 tokenID, address tokenAddress)
    {
        (address addr, ) = calculateFutureTokenAddress(targetTokenID);
        return {value: 0, flag: 128}(targetTokenID, addr);
    }

    //========================================
    //
    constructor(address ownerAddress, address initiatorAddress, string metadata) public reserve returnChangeTo(initiatorAddress)
    {
        if(msg.isExternal){    tvm.accept();    }
        require(ownerAddress != addressZero, ERROR_MESSAGE_OWNER_CAN_NOT_BE_ZERO);
        
        // Collection configuration
        _tokensIssued = 0;
        _ownerAddress = ownerAddress;
        _metadata     = metadata;
    }

    //========================================
    //
    function createToken(
        address ownerAddress,
        address authorityAddress,
        address initiatorAddress,
        string  metadata) external onlyOwner reserve returns (address tokenAddress)
    {
        require(msg.value >= gasToValue(400000, address(this).wid), ERROR_VALUE_NOT_ENOUGH_TO_MINT); // TODO: adjust value

        (address addr, TvmCell stateInit) = calculateFutureTokenAddress(_tokensIssued);
        emit mint(_tokensIssued, addr, ownerAddress, initiatorAddress);

        new BasicToken{value: 0, flag: 128, stateInit: stateInit}(
            ownerAddress,
            authorityAddress,
            initiatorAddress,
            metadata);

        _tokensIssued += 1;
        return addr;
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
