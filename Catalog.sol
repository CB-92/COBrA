pragma solidity ^0.4.23;
import "./BaseContentManagement.sol";

contract Catalog {
    address public creator;
    uint contentPrice;
    uint premiumTime;
    uint premiumPrice;
    bytes32[] contentList;
    uint public paymentDelay;
    uint allTheViews;

    struct ContentMetadata{
        address authorAddress;
        bool isLinked;
        BaseContentManagement content;
        uint views;
        uint viewsSincePayed;
    }

    mapping(bytes32 => ContentMetadata) addedContents;

    constructor() public{
        creator = msg.sender;
        /* 1 day = (24 h * 60 min * 60 sec) / 14.93 seconds per block = 53788 blocks */
        premiumTime = 53788;
        contentPrice = 100;
        premiumPrice = 500;
        paymentDelay = 5;
        allTheViews = 0;
    }

    /* events */
    event AccessGranted(bytes32 _content, address _user);
    event NewLinkedContent(bytes32 _content);
    event PaymentAvailable(bytes32 _content);
    event ClosedCatalog();

    /* user address => block number of premium subscription*/
    mapping (address => uint) premiumUsers;

    /* modifier to restrict a functionality only to Premium users */
    modifier restrictToPremium{
        require(
            premiumUsers[msg.sender] + premiumTime > block.number,
            "Access restricted to Premium accounts!"
        );
        _;
    }

    modifier ifLinkedContent(bytes32 _content){
        require(
            addedContents[_content].isLinked == true,
            "Content not linked to the catalog!"
        );
        _;
    }

    /* Functionalities restricted to catalog creator only */
    modifier onlyCreator{
        require(
            msg.sender == creator,
            "Only Catalog creator could perform this action"
        );
        _;
    }

    /* Check that the caller is the content */
    modifier onlyContent(bytes32 _content){
        require(
            addedContents[_content].authorAddress == msg.sender,
            "Action allowed only for content contract!"  
        );
        _;
    }

    /* Check content views */
    modifier checkViews(bytes32 _content){
        require(
            addedContents[_content].viewsSincePayed >= paymentDelay,
            "No views enough to be payed!"
        );
        _;
    }

    /* Check payment value: transaction refused if value < amount and if value > amount */
    modifier costs(uint _amount){
        require(
            msg.value == _amount,
            "You didn't pay the correct amount of money!"
        );
        _;
    }

    /* Check if the content list is empty */
    modifier ifNotEmpty{
        require(
            contentList.length != 0,
            "Content list is empty!"
        );
        _;
    }

    function getCatalogAddress() external view returns(address){
        return address(this);
    }

    function LinkToTheCatalog(bytes32 _title) external {
        contentList.push(_title);
        addedContents[_title].authorAddress = msg.sender;
        addedContents[_title].content = BaseContentManagement(msg.sender);
        addedContents[_title].views = 0;
        addedContents[_title].viewsSincePayed = 0;
        addedContents[_title].isLinked = true;
        emit NewLinkedContent(_title);
    }

    function GetStatistics() external view ifNotEmpty returns (bytes32[], uint[]) {
        uint[] memory views = new uint[](contentList.length);
        for(uint i = 0; i < contentList.length; i++){
            views[i] = addedContents[contentList[i]].views;
        }
        return (contentList, views);
    }

    function GetContentList() external view ifNotEmpty returns (bytes32[]) {
        return contentList;
    }

    function GetNewContentsList(uint _x) external view ifNotEmpty returns (bytes32[]){
        bytes32[] memory latests = new bytes32[](_x);
        uint j = contentList.length - 1;
        for (uint i = _x - 1; i>=0; i--){
            latests[i] = contentList[j];
            j--;
            if(i==0) break;
        }
        return latests;
    }

    function GetLatestByGenre(bytes32 _genre) external view ifNotEmpty returns (bytes32){
        bytes32 tmp;
        for (uint i = contentList.length - 1; i>=0; i--){
            if (addedContents[contentList[i]].content.genre() == _genre){
                tmp = contentList[i];
                break;
            }
            if(i == 0)
                break;
        }
        return tmp;
    }

    function GetMostPopularByGenre(bytes32 _genre) external view ifNotEmpty returns (bytes32){
        uint max = 0;
        bytes32 tmp;
        for(uint i = 0; i<contentList.length; i++){
            if(addedContents[contentList[i]].content.genre() == _genre && 
            addedContents[contentList[i]].views > max){
                max = addedContents[contentList[i]].views;
                tmp = contentList[i];
            }
        }
        return tmp;
    }

    function GetLatestByAuthor(bytes32 _author) external view ifNotEmpty returns (bytes32){
        bytes32 tmp;
        for (uint i = contentList.length - 1; i>=0; i--){
            if (addedContents[contentList[i]].content.author() == _author){
                tmp = contentList[i];
                break;
            }
            if(i == 0)
                break;
        }
        return tmp;

    }

    function GetMostPopularByAuthor(bytes32 _author) external view ifNotEmpty returns(bytes32){
        uint max = 0;
        bytes32 tmp;
        for(uint i = 0; i<contentList.length; i++){
            if(addedContents[contentList[i]].content.author() == _author &&
            addedContents[contentList[i]].views > max){
                max = addedContents[contentList[i]].views;
                tmp = contentList[i];
            }
        }
        return tmp;
    }

    function IsPremium(address _user) external view returns (bool){
        if(premiumUsers[_user] + premiumTime > block.number)
            return true;
        else return false;
    }

    function GetContent(bytes32 _content) external payable costs(contentPrice) ifLinkedContent(_content) returns (address){
        addedContents[_content].content.grantAccess(msg.sender);
        emit AccessGranted(_content, msg.sender);
        return addedContents[_content].authorAddress;
    }

    function GetContentPremium(bytes32 _content) external restrictToPremium  ifLinkedContent(_content) returns (address){
        addedContents[_content].content.grantAccess(msg.sender);
        emit AccessGranted(_content, msg.sender);
        return addedContents[_content].authorAddress;
    }

    function GiftContent(bytes32 _content, address _user) external payable costs(contentPrice) ifLinkedContent(_content) returns(address){
        addedContents[_content].content.grantAccess(_user);
        emit AccessGranted(_content, _user);
        return addedContents[_content].authorAddress;
    }

    function GiftPremium(address _user) external payable costs(premiumPrice) {
        premiumUsers[_user] = block.number;
    }

    function BuyPremium() external payable costs(premiumPrice){
        premiumUsers[msg.sender] = block.number;
    }

    /* Add views to a content and emit an event if it reaches the views for a payment */
    function AddViews(bytes32 _content) external onlyContent(_content){
        addedContents[_content].views++;
        addedContents[_content].viewsSincePayed++;
        allTheViews++;
        if(addedContents[_content].viewsSincePayed == 5)
            emit PaymentAvailable(_content); 
    }

    // @notice to be simulated manually for the moment, with the frontend there will be a callback
    function CollectPayment(bytes32 _content) external checkViews(_content) {
        msg.sender.transfer(paymentDelay * contentPrice);
        addedContents[_content].viewsSincePayed = 0;
    }

    function CloseCatalog() external onlyCreator{
        for(uint i = 0; i<contentList.length; i++){
            uint toTransfer = address(this).balance * addedContents[contentList[i]].views / allTheViews;
            addedContents[contentList[i]].authorAddress.transfer(toTransfer);
            emit ClosedCatalog();
        }
        selfdestruct(creator);
    }

}