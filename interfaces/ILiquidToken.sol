pragma ton-solidity >=0.55.0;
pragma AbiHeader time;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

//================================================================================
//
import "../interfaces/IBasicToken.sol";

//================================================================================
//
// Metadata JSON format:
// schema              - "Liquid Token".
// name                - Human readable name of the asset.
// description         - Human readable description of the asset.
// preview             - URL to the image of the asset. PNG, GIF and JPG file formats are supported. 
//                       You may use the ?ext={file_extension} query to provide information on the file type.
// external_url        - URL to an external application or website where users can also view the asset.
// files               - Object array, where an object should contain the uri and type of the file that is part of the asset. 
//                       The type should match the file extension. The array will also include files specified in image and animation_url fields, 
//                       and any other that are associated with the asset. You may use the ?ext={file_extension} query to provide information on the file type.
// attributes          - Object array, where an object should contain trait_type and value fields. value can be a string or a number.
//
// EXAMPLE:
//{
//    "schema": "Liquid Token",
//    "name": "Everscale NFT",
//    "description": "Never gonna give you up!",
//    "preview": {
//        "uri": "https://gateway.pinata.cloud/ipfs/QmYoiSjZUotKiYhMfzUSRWYTZUDq6MCCkXAbDPdC2TbdpU",
//        "mime_type": "image/png"
//    }
//    "external_url": "https://freeton.org",
//    "attributes": [
//        {
//            "trait_type": "Background",
//            "value": "Green"
//        },
//        {
//            "trait_type": "Foot",
//            "value": "Right"
//        },
//        {
//            "trait_type": "Rick",
//            "value": "Roll"
//        }
//    ],
//    "files": [
//        {
//            "uri": "https://gateway.pinata.cloud/ipfs/QmYoiSjZUotKiYhMfzUSRWYTZUDq6MCCkXAbDPdC2TbdpU",
//            "mime_type": "image/png"
//        }
//    ]
//}

//================================================================================
// Structure representing NFT creator share, in a perfect world creators get their
// part of every sale and this one defines the amount each creator gets.
//
struct CreatorShare
{
    address creatorAddress; // 
    uint16  creatorShare;   // 100 = 1% share
}

//================================================================================
//
interface ILiquidToken is IBasicToken
{
    //========================================
    // Events
    event metadataChanged();
    event printCreated(uint256 printID, address printAddress);

    //========================================
    /// @notice Returns NFT information;
    ///
    /// @param includeMetadata - If metadata should be included;
    ///
    /// Return values:
    ///     collectionAddress        - Token collection address;
    ///     tokenID                  - Token ID;
    ///     ownerAddress             - NFT owner;
    ///     authroityAddress         - NFT authority that can change the owner and authority itself, needed for staking, farming, auctions, etc.;
    ///     metadata                 - Token metadata in JSON format;
    ///     primarySaleHappened      - If 100% of the first sale should be distributed between the creators list;
    ///     metadataIsMutable        - Boolean if metadata is mutable and can be changed;
    ///     metadataAuthorityAddress - Address of an authority who can update metadata (if it is mutable);
    ///     printSupply              - Current amount of copies if the token can be printed;
    ///     printMaxSupply           - Maximum amount of copies if the token can be printed;
    ///     printLocked              - If print is available or locked;
    ///     printNumber              - Master edition (original token) always has `editionNumber` = 0, printed versions have 1+;
    ///     creatorsPercent          - Defines how many percent creators get when NFT is sold on a secondary market;
    ///     creatorsShares           - Defines a list of creators with their shares;
    //
    function getInfo(bool includeMetadata) external view responsible returns (
        address        collectionAddress,
        uint256        tokenID,
        address        ownerAddress,
        address        authorityAddress,
        string         metadata,
        bool           metadataLocked,
        address        metadataAuthorityAddress,
        bool           primarySaleHappened,
        uint256        printSupply,
        uint256        printMaxSupply,
        bool           printLocked,
        uint256        printNumber,
        uint16         creatorsPercent,
        CreatorShare[] creatorsShares);

    //========================================
    /// @notice Changes NFT metadata if `metadataIsMutable` is `true`;
    ///
    /// @param metadata - New metadata in JSON format;
    //
    function setMetadata(string metadata) external;
    
    //========================================
    /// @notice Locks NFT metadata;
    //
    function lockMetadata() external;
    
    //========================================
    /// @notice Prints a copy of the NFT;
    ///         Sometimes when you need multiple copies of the same NFT you can.. well..
    ///         create multiple copies of the same NFT (like coins or medals etc.) 
    ///         and they will technically different NFTs but at the same time logically 
    ///         they will be the same. Printing allows you to have multiple copies of the 
    ///         same NFT (with the same `tokenID`) distributed to any number of people. Every
    ///         one of them will be able to sell or transfer their own copy;
    //
    function printCopy(address targetOwnerAddress) external;
    
    //========================================
    /// @notice Locks NFT printing;
    //
    function lockPrint() external;
}

//================================================================================
//
