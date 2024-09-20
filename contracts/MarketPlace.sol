// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721 {
    address public marketplaceOwner;
    uint256 public currentTokenId = 1;

    struct NFT {
        address nftOwner;
        uint256 salePrice;
        bool availableForSale;
    }

    mapping(uint256 => NFT) public nfts;

    constructor() ERC721("NFT Marketplace", "NFTM") {
        marketplaceOwner = msg.sender;
    }

    function mintNFT(address _nftOwner, uint256 _salePrice) external returns (uint256) {
        require(msg.sender == marketplaceOwner, "Only marketplace owner can mint NFTs");
        uint256 newTokenId = currentTokenId++;
        _safeMint(_nftOwner, newTokenId);
        nfts[newTokenId] = NFT(_nftOwner, _salePrice, false);
        return newTokenId;
    }

    function listNFTForSale(uint256 _tokenId, uint256 _salePrice) external {
        require(msg.sender == nfts[_tokenId].nftOwner, "Only NFT owner can list for sale");
        require(nfts[_tokenId].availableForSale == false, "NFT is already listed for sale");
        nfts[_tokenId].salePrice = _salePrice;
        nfts[_tokenId].availableForSale = true;
    }

    function purchaseNFT(uint256 _tokenId) external payable {
        require(nfts[_tokenId].availableForSale == true, "NFT is not available for sale");
        require(msg.value >= nfts[_tokenId].salePrice, "Insufficient Ether to purchase NFT");
        address previousOwner = nfts[_tokenId].nftOwner;
        nfts[_tokenId].availableForSale = false;
        nfts[_tokenId].salePrice = 0;
        _transfer(previousOwner, msg.sender, _tokenId);
    }
}
