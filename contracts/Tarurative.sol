//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./Base64.sol";

//                            ■■■■          ■■■■        
//          ■■■■■■          ■■■■■■        ■■■■■■        
//          ■■■■■■    ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//          ■■■■■■    ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//          ■■■■■■            ■■■■■■    ■■■■            
//      ■■■■■■■■■■■■■■  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■    
//    ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//          ■■■■■■    ■■■■■■    ■■■■  ■■■■■■    ■■■■■■  
//          ■■■■■■    ■■■■■■■■■■■■■■  ■■■■■■■■■■■■■■■■  
//        ■■■■■■■■■■  ■■■■■■■■■■■■      ■■■■■■■■■■■■■■  
//        ■■■■■■■■■■  ■■■■■■                    ■■■■■■  
//        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//      ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//      ■■■■■■■■■■■■■■■■■■■■                    ■■■■■■  
//    ■■■■■■■■■■■■  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//    ■■■■■■■■■■■■      ■■■■■■■■■■■■■■■■■■■■■■■■■■■■    
//    ■■■■  ■■■■■■                          ■■■■■■      
//    ■■■■  ■■■■■■    ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//          ■■■■■■    ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
//          ■■■■■■        ■■■■              ■■■■■■      
//          ■■■■■■        ■■■■■■            ■■■■■■      
//          ■■■■■■        ■■■■■■■■          ■■■■■■      
//          ■■■■■■          ■■■■■■  ■■■■■■■■■■■■■■      
//          ■■■■                ■■    ■■■■■■■■■■■■      

contract Tarurative is ERC721Enumerable, ERC2981, AccessControl, Ownable {
    using Strings for uint256;

    constructor() ERC721("Taru", "TARU") {
        transferOwnership(0x89B65Dfa73937aeCd4ab400BDC15956e12D42Ef2);
    }

    address public supporterAddress = 0xcFE19606dA832969D6ef90Ad565616f5177541d8;

    modifier onlySupporter {
        _checkSupporter();
        _;
    }
    function _checkSupporter() internal view {
        require(msg.sender == owner() || msg.sender == supporterAddress, 'access denied');
    }

    uint256 public MAX_SUPPLY = 2300;
    uint256 private nextTokenId = 1;

    string public BASE64_HEAD = "data:application/json;base64,";
    string public baseImageURI = '';
    string public baseAnimationURI = '';
    string public baseImageExtension = '.png';
    string public baseAnimationExtension = '.glb';
    string public hiddenMetadataUri = '';
    string public description = '';
    string public externalUrl = '';

    uint256 public publicPrice = 5 ether;
    uint256 public maxTaruMemberMintAmt = 10;
    uint256 public maxWhitelistMintAmt = 5;
    mapping(address => uint256) public taruWhitelist; // Whitelist of Taru members
    mapping(address => uint256) public whitelist; // Whitelist

    bool public publicSale = false;
    bool public paused = true;
    bool public revealed = false;

    address public royaltyAddress = 0x89B65Dfa73937aeCd4ab400BDC15956e12D42Ef2;
    uint96 public royaltyFee = 1000;

    struct CollabTaruInfo {
        string name;
        address account;
        string imageUrl;
        string animationUrl;
        bool hasCollab;
    }

    mapping(uint256 => CollabTaruInfo) public collabTaruInfo; // tokenId -> CollabTaruInfo
    mapping(uint256 => bool) public poorTaurus; // tokenId -> bool (if poor taru true)

    function mint(uint256 amt) public payable {
        require(!paused, 'mint is not available now');
        require(publicSale, 'public sale is not live');
        require(totalSupply() + amt <= MAX_SUPPLY, 'mint is over');
        require(msg.value >= publicPrice * amt, 'not enough value');
        for (uint256 i=0; i<amt; i++) {
            _safeMint(msg.sender, nextTokenId);
            nextTokenId++;
        }
    }

    function mintTaruMember(uint256 amt) public {
        require(!paused, 'mint is not available now');
        require(!publicSale, 'private sale is over');
        require(totalSupply() + amt <= MAX_SUPPLY, 'mint is over');
        require(taruWhitelist[msg.sender] - amt >= 0, 'you cannot mint');
        taruWhitelist[msg.sender] -= amt;
        for (uint256 i=0; i<amt; i++) {
            _safeMint(msg.sender, nextTokenId);
            nextTokenId++;
        }
    }

    function mintWhitelist(uint256 amt) public {
        require(!paused, 'mint is not available now');
        require(!publicSale, 'private sale is over');
        require(totalSupply() + amt <= MAX_SUPPLY, 'mint is over');
        require(whitelist[msg.sender] - amt >= 0, 'you cannot mint');
        whitelist[msg.sender] -= amt;
        for (uint256 i=0; i<amt; i++) {
            _safeMint(msg.sender, nextTokenId);
            nextTokenId++;
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        string memory metadata;

        // Unrevealed
        if (!revealed) {
            metadata = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "TARU #',
                            tokenId.toString(),
                            '", "description": "',
                            description,
                            '", "image": "',
                            hiddenMetadataUri,
                            '"}'
                        )
                    )
                )
            );
            return string(
                abi.encodePacked(BASE64_HEAD, metadata)
            );
        }

        string memory taruImageUri = string(abi.encodePacked(baseImageURI, tokenId.toString(), baseImageExtension));
        string memory taruAnimationUri = string(abi.encodePacked(baseAnimationURI, tokenId.toString(), baseAnimationExtension));

        // Poor Taurus
        if (isPoorTaurus(tokenId)) {
            metadata = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "TARU #',
                            tokenId.toString(),
                            '", "description": "',
                            description,
                            '", "image": "',
                            taruImageUri,
                            '", "animation_url": "',
                            taruAnimationUri,
                            '", "external_url": "',
                            externalUrl,
                            '", "attributes": [{"trait_type": "There,there...", "value": "',
                            unicode'かわいそうな樽',
                            '"}]}'
                        )
                    )
                )
            );
            return string(
                abi.encodePacked(BASE64_HEAD, metadata)
            );
        }

        // Set Collaboration Image Url
        if (bytes(collabTaruInfo[tokenId].imageUrl).length > 0) {
            taruImageUri = collabTaruInfo[tokenId].imageUrl;
            taruAnimationUri = collabTaruInfo[tokenId].animationUrl;
            metadata = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "TARU #',
                            tokenId.toString(),
                            '", "description": "',
                            description,
                            '", "image": "',
                            taruImageUri,
                            '", "animation_url": "',
                            taruAnimationUri,
                            '", "external_url": "',
                            externalUrl,
                            '", "attributes": [{"trait_type": "collaborator", "value": "',
                            collabTaruInfo[tokenId].name,
                            '"}, {"trait_type": "address", "value": "',
                            Strings.toHexString(uint256(uint160(collabTaruInfo[tokenId].account)), 20),
                            '"}]}'
                        )
                    )
                )
            );
            return string(
                abi.encodePacked(BASE64_HEAD, metadata)
            );
        }

        // Normal
        metadata = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
						'{"name": "TARU #',
						tokenId.toString(),
						'", "description": "',
						description,
						'", "image": "',
                        taruImageUri,
                        '", "animation_url": "',
                        taruAnimationUri,
                        '", "external_url": "',
                        externalUrl,
                        '"}'
                    )
                )
            )
        );
        return string(
            abi.encodePacked(BASE64_HEAD, metadata)
        );
    }

    function setCollabTaruInfo(uint256 tokenId, string calldata collaborator, string calldata imageUrl, string calldata animationUrl) public {
        require(ownerOf(tokenId) == msg.sender, 'not owner');
        require(collabTaruInfo[tokenId].account == msg.sender || !collabTaruInfo[tokenId].hasCollab, 'taru has changed');
        collabTaruInfo[tokenId].name = collaborator;
        collabTaruInfo[tokenId].account = msg.sender;
        collabTaruInfo[tokenId].imageUrl = imageUrl;
        collabTaruInfo[tokenId].animationUrl = animationUrl;
        collabTaruInfo[tokenId].hasCollab = true;
    }

    function setTaruWhiteList(address[] calldata addresses) public onlySupporter {
        uint256 arrayLength = addresses.length;
        for (uint256 i=0; i<arrayLength; i++) {
            taruWhitelist[addresses[i]] = maxTaruMemberMintAmt;
        }
    }

    function setWhitelist(address[] calldata addresses) public onlySupporter {
        uint256 arrayLength = addresses.length;
        for (uint256 i=0; i<arrayLength; i++) {
            whitelist[addresses[i]] = maxWhitelistMintAmt;
        }
    }

    // Poor Taurus
    function thereTherePoorTaurus(uint256 tokenId) public onlyOwner {
        collabTaruInfo[tokenId].name = '';
        collabTaruInfo[tokenId].account = 0x0000000000000000000000000000000000000000;
        collabTaruInfo[tokenId].imageUrl = '';
        collabTaruInfo[tokenId].animationUrl = '';
        poorTaurus[tokenId] = true;
    }

    function isPoorTaurus(uint256 tokenId) public view returns (bool) {
        return poorTaurus[tokenId];
    }

    function setPublicSale() public onlySupporter {
        publicSale = true;
    }

    function isPublicSale() public view returns (bool) {
        return publicSale;
    }

    function maxSupply() public view returns (uint256) {
        return MAX_SUPPLY;
    }

    function reveal() public onlySupporter {
        revealed = true;
    }

    function pause() public onlySupporter {
        paused = true;
    }

    function unpause() public onlySupporter {
        paused = false;
    }

    function setSupporterAddress(address _address) external onlyOwner {
        supporterAddress = _address;
    }

    function revokeSupporterAddress() external onlySupporter {
        supporterAddress = 0x0000000000000000000000000000000000000000;
    }

    function setHiddenMetadataUri(string calldata uri) external onlySupporter {
        hiddenMetadataUri = uri;
    }

    function setBaseImageURI(string calldata uri) public onlySupporter {
        baseImageURI = uri;
    }

    function setBaseAnimationURI(string calldata uri) public onlySupporter {
        baseAnimationURI = uri;
    }

    function setDescription(string calldata newDescription) public onlySupporter {
        description = newDescription;
    }

    function setBaseImageExtension(string calldata newBaseExtension) public onlySupporter {
        baseImageExtension = newBaseExtension;
    }

    function setBaseAnimationExtension(string calldata newBaseExtension) public onlySupporter {
        baseAnimationExtension = newBaseExtension;
    }

    function setExternalUrl(string calldata url) public onlySupporter {
        externalUrl = url;
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address] > 0;
    }

    function isTaruWhitelisted(address _address) public view returns (bool) {
        return taruWhitelist[_address] > 0;
    }

    function setRoyaltyFee(uint96 fee) external onlyOwner {
        royaltyFee = fee;
        _setDefaultRoyalty(royaltyAddress, fee);
    }

    function setRoyaltyAddress(address _address) external onlyOwner {
        royaltyAddress = _address;
        _setDefaultRoyalty(_address, royaltyFee);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(getBalance());
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (ERC721Enumerable, ERC2981, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}