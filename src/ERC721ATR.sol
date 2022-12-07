// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "./ATRToken.sol";


contract ERC721ATR is ERC721 {

    bytes32 internal constant ATRTokenSalt = bytes32(uint256(keccak256("AssetTransferRightsToken")) - 1);

    ATRToken public immutable atr;


    constructor() ERC721("NFT with tokenizable transfer rights", "721ATR") {
        atr = new ATRToken{ salt: ATRTokenSalt }();
    }


    // # mint / burn ATR token

    function mintTransferRights(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "Caller is not token owner");
        atr.mint(owner, tokenId);
    }

    function burnTransferRights(uint256 tokenId) external {
        address owner = atr.ownerOf(tokenId);
        require(msg.sender == owner, "Caller is not token owner");
        atr.burn(tokenId);
    }


    // # updated transfer constraints

    function hasTransferRights(address owner, uint256 tokenId) public view returns (bool) {
        return atr.ownerOf(tokenId) == owner;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) override internal view virtual returns (bool) {
        if (atr.exists(tokenId)) {
            return hasTransferRights(spender, tokenId);
        } else {
            address owner = ownerOf(tokenId);
            return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
        }
    }

}
