pragma solidity 0.4.23;

import "./BaseContentManagement.sol";

contract ContentManagement is BaseContentManagement{
    Catalog private catalog;
    
    constructor(bytes32 _title, bytes32 _author, bytes32 _genre, address _catalogAddress) public{
        title = _title;
        author = _author;
        genre = _genre;
        catalogAddress = _catalogAddress;
        views = 0;
        viewsSincePayed = 0;
        catalog = Catalog(catalogAddress);
        catalog.LinkToTheCatalog(title);
    }

    event PaymentAvailable(bytes32 id);

    function grantAccess(address _user) external isCatalog{
        allowedUsers[_user] = true;
    }

    function consumeContent() external onlyIfAllowed() returns(bytes32){
        allowedUsers[msg.sender] = false;
        if(catalog.IsPremium(msg.sender)==false){
            views++;
            viewsSincePayed++;
        }

        if(viewsSincePayed == catalog.paymentDelay()){
            //Catalog(catalogAddress).CollectPayment();
            viewsSincePayed = 0;
            emit PaymentAvailable(title);
        }

        return content;
    }
}