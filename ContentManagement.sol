pragma solidity 0.4.23;

import "./BaseContentManagement.sol";

contract MusicContentManagement is BaseContentManagement{

    bytes32 private encoding;
    uint private bitrate;
    uint private duration;
    
    constructor(bytes32 _title, bytes32 _author, bytes32 _encoding, uint _bitrate, uint _duration, address _catalogAddress) public{
        title = _title;
        author = _author;
        genre = "736f6e67";
        encoding = _encoding;
        bitrate = _bitrate;
        duration = _duration;
        catalogAddress = _catalogAddress;
        catalog = Catalog(catalogAddress);
        catalog.LinkToTheCatalog(title);
    }

    function consumeContent() external onlyIfAllowed() returns(bytes32 _encoding, uint _bitrate, uint _duration){
        allowedUsers[msg.sender] = false;
        if(catalog.IsPremium(msg.sender)==false){
            catalog.AddViews(title);
        }

        _encoding = encoding;
        _bitrate = bitrate;
        _duration = duration;
    }
}

contract BookContentManagement is BaseContentManagement{

    bytes32 private encoding;
    uint private pages;
    
    constructor(bytes32 _title, bytes32 _author, bytes32 _encoding, uint _pages, address _catalogAddress) public{
        title = _title;
        author = _author;
        genre = "626f6f6b";
        encoding = _encoding;
        pages = _pages;
        catalogAddress = _catalogAddress;
        catalog = Catalog(catalogAddress);
        catalog.LinkToTheCatalog(title);
    }

    function consumeContent() external onlyIfAllowed() returns(bytes32 _encoding, uint _pages){
        allowedUsers[msg.sender] = false;
        if(catalog.IsPremium(msg.sender)==false){
            catalog.AddViews(title);
        }

        _encoding = encoding;
        _pages = pages;
    }
}

contract MovieContentManagement is BaseContentManagement{

    bytes32 private encoding;
    uint private bitrate;
    uint private duration;
    uint private width;
    uint private height;
    
    constructor(bytes32 _title, bytes32 _author, bytes32 _encoding, uint _bitrate, uint _duration, 
    uint _width, uint _height, address _catalogAddress) public{
        title = _title;
        author = _author;
        genre = "6d6f766965";
        encoding = _encoding;
        bitrate = _bitrate;
        duration = _duration;
        width = _width;
        height = _height;
        catalogAddress = _catalogAddress;
        catalog = Catalog(catalogAddress);
        catalog.LinkToTheCatalog(title);
    }

    function consumeContent() external onlyIfAllowed() returns(bytes32 _encoding, uint _bitrate, uint _duration, uint _width, uint _height){
        allowedUsers[msg.sender] = false;
        if(catalog.IsPremium(msg.sender)==false){
            catalog.AddViews(title);
        }

        _encoding = encoding;
        _bitrate = bitrate;
        _duration = duration;
        _width = width;
        _height = height;
    }
}