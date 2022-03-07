pragma ton-solidity >=0.55.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/IBase.sol";
import "../interfaces/IBasicToken.sol";
import "../interfaces/IBasicCollection.sol";

//================================================================================
//
struct StakeInfo
{
    bool    confirmed;
    uint32  dt;
    uint256 tokenID;
    address ownerAddress;
    address initiatorAddress;
    TvmCell payload;
}

//================================================================================
//
contract BasicStaking is IBasicTokenSetAuthorityCallback, IBase
{
    //========================================
    // Error codes
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER      = 100;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_COLLECTION = 102;
    uint constant ERROR_MESSAGE_TOKEN_NOT_STAKED            = 200;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_TOKEN_OWNER   = 201;
    uint constant ERROR_WRONG_COLLECTION_ADDRESS            = 202;

    //========================================
    // Events
    event tokenStaked  (address tokenAddress, uint256 tokenID, address collectionAddress);
    event tokenUnstaked(address tokenAddress, uint256 tokenID, address collectionAddress);
    event tokenStakeConfirmed(address tokenAddress, uint256 tokenID, address collectionAddress);

    //========================================
    // Variables
    uint256 static _nonce;             //
    // Addresses
    address        _ownerAddress;      //
    address static _collectionAddress; // Collection for staking 
    //
    mapping(address => StakeInfo) _stakedTokens; // You can collect any information here like staking start date, ownerAddress, etc...

    //========================================
    // Modifiers
    modifier onlyCollection {    require(_checkSenderAddress(_collectionAddress), ERROR_MESSAGE_SENDER_IS_NOT_MY_COLLECTION);    _;    }
    modifier onlyOwner      {    require(_checkSenderAddress(_ownerAddress),      ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);         _;    }
    //modifier onlyAuthority  {    require(_checkSenderAddress(_authorityAddress),  ERROR_MESSAGE_SENDER_IS_NOT_MY_AUTHORITY);     _;    }

    //========================================
    //
    constructor(address ownerAddress,
                address initiatorAddress) public reserve returnChangeTo(initiatorAddress)
    {
        tvm.accept();
        _ownerAddress = ownerAddress;
    }
    
    //========================================
    //
    function getInfo() external view returns (
        uint256 nonce,
        address ownerAddress,
        address collectionAddress,
        mapping(address => StakeInfo) 
                stakedTokens)
    {
        return (
            _nonce,
            _ownerAddress,
            _collectionAddress,
            _stakedTokens);
    }

    //========================================
    //
    function setOwner(address ownerAddress) external onlyOwner reserve returnChange
    {
        _ownerAddress = ownerAddress; //
    }

    //========================================
    //
    function onSetAuthorityCallback(
        address collectionAddress,
        uint256 tokenID,
        address ownerAddress,
        address initiatorAddress,
        TvmCell payload) external override reserve
    {
        require(collectionAddress == _collectionAddress, ERROR_WRONG_COLLECTION_ADDRESS);

        emit tokenStaked(msg.sender, tokenID, collectionAddress);

        StakeInfo info;
        info.confirmed        = false; // not confirmed
        info.dt               = now;
        info.tokenID          = tokenID;
        info.ownerAddress     = ownerAddress;
        info.initiatorAddress = initiatorAddress;
        info.payload          = payload;

        _stakedTokens[msg.sender] = info;
        IBasicCollection(_collectionAddress).getTokenAddress{value: 0, flag: 128, bounce: true, callback: onGetTokenAddressCallback}(tokenID);
        
    }

    //========================================
    //
    function onGetTokenAddressCallback(uint256 tokenID, address tokenAddress) public onlyCollection reserve
    {
        tokenID; // unused

        if(_stakedTokens.exists(tokenAddress))
        {
            emit tokenStakeConfirmed(msg.sender, tokenID, _collectionAddress);

            _stakedTokens[tokenAddress].confirmed = true;
            _stakedTokens[tokenAddress].initiatorAddress.transfer(0, false, 128);
        }
        else
        {
            _ownerAddress.transfer(0, false, 128);
        }
    }

    //========================================
    //
    function unstake(address tokenAddress) external reserve
    {
        require(_stakedTokens.exists(tokenAddress),                     ERROR_MESSAGE_TOKEN_NOT_STAKED);
        require(_stakedTokens[tokenAddress].ownerAddress == msg.sender, ERROR_MESSAGE_SENDER_IS_NOT_TOKEN_OWNER);

        emit tokenUnstaked(msg.sender, _stakedTokens[tokenAddress].tokenID, _collectionAddress);

        TvmCell empty;
        IBasicToken(tokenAddress).setAuthority{value: 0, flag: 128, bounce: false}(msg.sender, empty);
        delete _stakedTokens[tokenAddress];
    }
}

//================================================================================
//
