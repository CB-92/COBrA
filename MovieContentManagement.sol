pragma solidity 0.4.23;

import "./BaseContentManagement.sol";

contract MovieContentManagement is BaseContentManagement{

    bytes32 private encoding;
    uint private bitrate;
    uint private duration;
    uint private width;
    uint private height;
    
    constructor(bytes32 _title, bytes32 _author, bytes32 _encoding, uint _bitrate, uint _duration,
    uint _resolution, address _catalogAddress) public{
        title = _title;
        author = _author;
        genre = "6d6f766965";
        content.push(_encoding);
        content.push(bytes32(_bitrate));
        content.push(bytes32(_duration));
        content.push(bytes32(_resolution));
        catalogAddress = _catalogAddress;
        catalog = Catalog(catalogAddress);
        catalog.LinkToTheCatalog(title);
    }

    function grantAccess(address _user) external isCatalog{
        allowedUsers[_user] = true;
    }

    function consumeContent() external onlyIfAllowed() returns(bytes32[]){
        allowedUsers[msg.sender] = false;
        if(catalog.IsPremium(msg.sender)==false){
            catalog.AddViews(title);
        }

        return content;
    }
}