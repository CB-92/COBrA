pragma solidity ^0.4.23;
import "./BaseContentManagement.sol";

contract Catalog {
    address public creator;
    uint contentPrice;
    uint premiumTime;
    uint lastElementsNumber;
    uint premiumPrice;
    /* List of content identifiers */
    bytes32[] contentList;

    struct ContentMetadata{
        BaseContentManagement content;
        bool isLinked;
        uint views;
    }

    mapping(string => ContentMetadata) addedContents;

    constructor() public{
        creator = msg.sender;
        /* 1 month = (30 days * 24 h * 60 min * 60 sec) / 14 seconds per block = 185143 blocks */
        premiumTime = 185143;
    }

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

    /* Functionalities restricted to catalog creator only */
    modifier onlyCreator{
        require(
            msg.sender == creator,
            "Only Catalog creator could perform this action"
        );
        _;
    }

    /* Check account balance */
    modifier costs(uint _amount){
        require(
            msg.value == _amount,
            "You didn't pay the correct amount of money!"
        );
        _;
    }

    function GetStatistics() external view returns (bytes32[], uint[]){

    }

    function GetContentList() external view returns (bytes32[]) {
        return contentList;
    }

    function GetNewContentsList(uint _x) external view returns (bytes32[]){
        bytes32[] memory latests = new bytes32[](_x);
        uint j = contentList.length - 1;
        for (uint i = _x - 1; i>=0; i--){
            latests[i] = contentList[j];
            j--;
            if(i==0) break;
        }
        return latests;
    }

    function GetLatestByGenre(string _genre) external view returns (string){

    }

    function GetMostPopularByGenre(string _genre) external view returns (string){

    }

    function GetLatestByAuthor(string _autor) external view returns (string){

    }

    function GetMostPopularByAuthor(string _author) external view returns(string){

    }

    function IsPremium(address _user) external view returns (bool){
        if(premiumUsers[_user] + premiumTime > block.number)
            return true;
        else return false;
    }

    function GetContent(string _content) external payable costs(contentPrice){
        addedContents[_content].content.grantAccess(msg.sender);
    }

    function GetContentPremium(string _content) external restrictToPremium{
        addedContents[_content].content.grantAccess(msg.sender);
    }

    function GiftContent(string _content, address _user) external payable costs(contentPrice){
        addedContents[_content].content.grantAccess(_user);
    }

    function GiftPremium(address _user) external payable costs(premiumPrice){
        premiumUsers[_user] = block.number;
    }

    function BuyPremium() external payable costs(premiumPrice){
        premiumUsers[msg.sender] = block.number;
    }

    function ConsumeContent(string _content) external{
        addedContents[_content].content.consumeContent(msg.sender);
        addedContents[_content].views++;
    }

    function CloseCatalog() external onlyCreator{
        /* TODO: pagare autori in proporzione alle views */
        selfdestruct(creator);
    }

}