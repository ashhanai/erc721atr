// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";


contract ATRToken is ERC721 {

    address public immutable mainContract;

    modifier onlyMainContract() {
        require(msg.sender == mainContract, "Caller is not the main contract");
        _;
    }


    constructor() ERC721("Asset Transfer Rights Token", "ATR") {
        mainContract = msg.sender;
    }


    function mint(address to, uint256 tokenId) external onlyMainContract {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external onlyMainContract {
        _burn(tokenId);
    }


    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

}
