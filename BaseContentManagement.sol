pragma solidity ^0.4.23;
import "./Catalog.sol";
import "./StringLib.sol";

contract BaseContentManagement {
    bytes32 public title;
    bytes32 public author;
    bytes32 public genre;
    bytes32 content;
    uint public views;
    uint public viewsSincePayed;
    address catalogAddress;

    mapping (address => bool) allowedUsers;

    constructor(string _title, string _author, string _genre, address _catalogAddress) public{
        title = StringLib.stringToBytes32(_title);
        author = StringLib.stringToBytes32(_author);
        genre = StringLib.stringToBytes32(_genre);
        catalogAddress = _catalogAddress;
        views = 0;
        viewsSincePayed = 0;
    }

    modifier onlyIfAllowed(){
        require(
            allowedUsers[msg.sender] == true,
            "User not allowed"
        );
        _;
    }

    modifier isCatalog{
        require(
            msg.sender == catalogAddress,
            "Only the Catalog could perform this action!"
        );
        _;
    }

    function grantAccess(address _user) external isCatalog{}

    function consumeContent(address _user) external isCatalog onlyIfAllowed() returns(bytes32){}
    
}