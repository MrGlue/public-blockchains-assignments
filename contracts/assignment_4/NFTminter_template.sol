// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../BaseAssignment.sol";
import "./INFTminter.sol";

contract NFTminter_template is ERC721URIStorage, BaseAssignment, INFTminter {
    // Use strings methods directly on variables.
    using Strings for uint256;
    using Strings for address;

    uint256 private _nextTokenId;
    uint256 private totalSupply = 0;
    uint256 private current_price = 0.0001 ether;
    bool private isSaleActive = true;

    // Other variables as needed ...

    address validator = 0x766483FE15F19112d9f6069d05e4eA4d24C4eFA5;
    string ipfs_hash = "bafkreihoeg2vsy6st3iy577o7gsnypw4quqi3g3znef7em44crsj3t2b6y";
    

    constructor(address owner) ERC721("Token", "TKN") BaseAssignment(validator) {
        _owner = owner;
    }

    // mint an nft and send to _address
    function mint(address _address) public payable returns (uint256) {
        require(isSaleActive);
        require(msg.value == current_price);
        current_price *= 2;
        uint256 tokenId = _nextTokenId++;

        // Return token URI
        string memory tokenURI = getTokenURI(tokenId, _address);

        // Mint ...
        _mint(_address, tokenId);
        totalSupply++;


        // Set encoded token URI to token
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }


    function burn(uint256 tokenId) external payable override {
        require(_ownerOf(tokenId) == msg.sender);
        require(msg.value == 0.0001 ether);
        current_price = 0.0001 ether;
        totalSupply--;
        _burn(tokenId);
    }

    function pauseSale() external override {
        require(msg.sender == _owner || isValidator(msg.sender));
        isSaleActive = false;
    }

    function activateSale() external override {
        require(msg.sender == _owner || isValidator(msg.sender));
        isSaleActive = true;
    }

    function getSaleStatus() external view override returns (bool) {
        return isSaleActive;
    }

    function withdraw(uint256 amount) external override {
        require(msg.sender == _owner || isValidator(msg.sender));
        msg.sender.transfer(amount);
    }

    function getPrice() external view override returns (uint256) {
        return current_price;
    }

    function getTotalSupply() external view override returns (uint256) {
        return totalSupply;
    }

    function getIPFSHash() external view override returns (string memory) {
        return ipfs_hash;
    }

    // Other methods as needed ...

    /*=============================================
    =                   HELPER                  =
    =============================================*/

    // Get tokenURI for token id
    function getTokenURI(
        uint256 tokenId,
        address newOwner
    ) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "My beautiful artwork #',
            tokenId.toString(),
            '",', 
            '"hash": "',
            ipfs_hash,
            '",',
            '"by": "',
            _owner,
            '",',
            '"new_owner": "',
            newOwner,
            '"',
            "}"
        );

        // Encode dataURI using base64 and return
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

}
