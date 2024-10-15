// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// to deploy that:
// forge create --rpc-url https://ethereum-sepolia-rpc.publicnode.com --account beam-test-1 contracts/mocks/MyERC721Mock.sol:MyERC721Mock --password 123 --legacy

contract MyERC721Mock is ERC721, Ownable {
    uint256 public tokenCounter;

    constructor() ERC721("DummyNFT", "DNFT") Ownable(msg.sender) {
        tokenCounter = 0; // Starts the token counter at 0
    }

    function mintNFT(address recipient) public onlyOwner returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(recipient, newItemId);
        tokenCounter += 1; // Increment the token counter for next mint
        return newItemId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://example.com/metadata/";
    }
}
