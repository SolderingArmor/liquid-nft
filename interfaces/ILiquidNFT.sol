pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
struct nftInfo
{
    uint32  dtCreated;     //
    address ownerAddress;  // Current owner;
    address authorAddress; // Author is never changed;
}

struct nftMedia
{
    bytes[] contents;  // Binary file in HEX;    
    bytes   extension; // File extension in a format of a mime-type e.g. "image/gif" or "image/png";
                       // For external media there are several ways of whowing the file, like hashsum or external link (why not?), and there are not mime types 
                       // for that kind of data (they both fall under "text/plain"), thus we suggest adding "text/hash" and "text/url" to standard mime-types,
                       // it will help distinguish plain text from hashes and URLs when parsing;
    bytes   name;      // (optional) NFT name,    author gives NFT a name    when created;
    bytes   comment;   // (optional) NFT comment, author gives NFT a comment when created;
    bool    isSealed;  // If the media is in the process of being changed or this NFT is final;
}

//================================================================================
//
abstract contract ILiquidNFT
{
    //========================================
    // Constants
    address constant addressZero = address.makeAddrStd(0, 0);

    //========================================
    // Error codes
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER       = 100;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_ROOT        = 101;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_MY_UPLOADER    = 102;
    uint constant ERROR_MESSAGE_SENDER_IS_NOT_EXTERNAL_MEDIA = 103;
    uint constant ERROR_MESSAGE_OWNER_CAN_NOT_BE_ZERO        = 104;
    uint constant ERROR_NOT_ENOUGH_BALANCE                   = 201;
    uint constant ERROR_MEDIA_IS_SEALED                      = 202;
    uint constant ERROR_MEDIA_IS_NOT_SEALED                  = 203;
    uint constant ERROR_PART_OUT_OF_RANGE                    = 204;
    uint constant ERROR_POTENTIAL_OUT_OF_GAS                 = 205;

    //========================================
    // Variables
    nftInfo  _info;           //
    nftMedia _media;          //
    uint256  _uploaderPubkey; //

    //========================================
    // Modifiers
    function _reserve() internal inline view {    tvm.rawReserve(gasToValue(10000, address(this).wid), 0);    }

    modifier onlyOwner   {    require(msg.isInternal && _info.ownerAddress == msg.sender && _info.ownerAddress != addressZero, ERROR_MESSAGE_SENDER_IS_NOT_MY_OWNER);       _;    }
    modifier onlyUploader{    require(msg.isExternal && msg.pubkey() == _uploaderPubkey  && _uploaderPubkey    != 0,           ERROR_MESSAGE_SENDER_IS_NOT_MY_UPLOADER);    _;    }
    modifier isSealed    {    require(_media.isSealed == true,  ERROR_MEDIA_IS_NOT_SEALED);    _;    }
    modifier isNotSealed {    require(_media.isSealed == false, ERROR_MEDIA_IS_SEALED    );    _;    }
    modifier reserve     {    _reserve();    _;                                                      }
    modifier returnChange{                   _; msg.sender.transfer(0, true, 128);                   }

    //========================================
    // Getters
    function  getInfo()           external             view         returns (nftInfo)  {    return                      (_info );             }
    function callInfo()           external responsible view reserve returns (nftInfo)  {    return {value: 0, flag: 128}(_info );             }
    function  getMedia()          external             view         returns (nftMedia) {    return                      (_media);             }
    function callMedia()          external responsible view reserve returns (nftMedia) {    return {value: 0, flag: 128}(_media);             }
    function  getOwnerAddress()   external             view         returns (address)  {    return                      (_info.ownerAddress); }
    function callOwnerAddress()   external responsible view reserve returns (address)  {    return {value: 0, flag: 128}(_info.ownerAddress); }
    function  getUploaderPubkey() external             view         returns (uint256)  {    return                      (_uploaderPubkey);    }
    function callUploaderPubkey() external responsible view reserve returns (uint256)  {    return {value: 0, flag: 128}(_uploaderPubkey);    }

    //========================================
    //
    function changeOwner(address newOwnerAddress) external onlyOwner isSealed reserve returnChange returns (address oldAddress, address newAddress)
    {
        oldAddress = _info.ownerAddress;
        _info.ownerAddress = newOwnerAddress;

        return (oldAddress, newOwnerAddress);
    }

    function callChangeOwner(address newOwnerAddress) external responsible onlyOwner isSealed returns (address oldAddress, address newAddress)
    {
        _reserve();
        oldAddress = _info.ownerAddress;
        _info.ownerAddress = newOwnerAddress;

        // Return the change
        return {value: 0, flag: 128}(oldAddress, newOwnerAddress);
    }

    //========================================
    //
    function sealMedia(bytes extension, bytes name, bytes comment) external onlyOwner isNotSealed
    {
        _media.extension = extension;
        _media.name      = name;
        _media.comment   = comment;
        _uploaderPubkey  = 0;
        _media.isSealed  = true;
    }

    //========================================
    //
    function _populateInfo(address ownerAddress, uint32 dtCreated) internal
    {
        _info.ownerAddress  = ownerAddress;
        _info.authorAddress = ownerAddress;
        _info.dtCreated     = dtCreated;
    }

    //========================================
    //
    function clearMedia() external
    {
        delete _media.contents;
    }

    //========================================
    //
    function _setMediaPart(uint256 partNum, uint256 partsTotal, bytes data) internal
    {
        if(partNum > _media.contents.length && (partNum - _media.contents.length) > 50)
        {
            revert(ERROR_POTENTIAL_OUT_OF_GAS);
        }

        while(_media.contents.length <= partNum && _media.contents.length <= partsTotal)
        {
            _media.contents.push("");
        }

        _media.contents[partNum] = data;
    }

    //========================================
    //
    function setMediaPart(uint256 partNum, uint256 partsTotal, bytes data) external onlyOwner isNotSealed reserve returnChange
    {
        _setMediaPart(partNum, partsTotal, data);
    }

    //========================================
    //
    function setMediaPartExternal(uint256 partNum, uint256 partsTotal, bytes data) external onlyUploader isNotSealed
    {
        tvm.accept();
        _setMediaPart(partNum, partsTotal, data);
    }

    // Function with predefined name which is used to replace custom replay protection.
    function afterSignatureCheck(TvmSlice body, TvmCell message) private inline pure returns (TvmSlice) 
    {
        message.depth(); // Shut the warning about unused variable;
                         // We don't care because the only external function is uploading media and we don't want 
                         // to have limits on that because only owner can do that, it's his TONs;

        body.decode(uint64); // timestamp
        body.decode(uint32); // dt

        return body;
    }


    //========================================
    //
    function touch() external view onlyOwner reserve returnChange
    { }
}

//================================================================================
//
