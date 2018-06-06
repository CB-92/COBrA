pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

contract StringLib {
    
    /*
        Source: 
        https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    */
    
    function bytes32ToString(bytes32 x) external pure returns (string) {
        
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
    
    
    function stringToBytes32(string _s) public pure returns(bytes32) {
        
        bytes32 tmp; // Required, not possible to assign state variables inside assembly {}
        assembly {
            tmp := mload(add(_s, 32))
        }
        
        return tmp;
    }
}