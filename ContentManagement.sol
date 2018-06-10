pragma solidity 0.4.23;

import "./BaseContentManagement.sol";

contract ContentManagement is BaseContentManagement{
    Catalog private catalog;
    
    constructor(string _title, string _author, string _genre, address _catalogAddress) public{
        title = StringLib.stringToBytes32(_title);
        author = StringLib.stringToBytes32(_author);
        genre = StringLib.stringToBytes32(_genre);
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