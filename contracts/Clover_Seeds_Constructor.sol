pragma solidity 0.8.12;

// SPDX-License-Identifier: MIT

import "./Ownable.sol";
import "./ITContract.sol";

contract Clover_Seeds_Constructor is Ownable {
    address private originNFTContract;
    address private newNFTContract;
    uint256 public totalAirDrops;
    uint256 public currentAirDrops;

    constructor() {}

    function setTotalAirDrops(uint256 amount) public onlyOwner {
        totalAirDrops = amount;
    }

    function setContractAcc(address _originNFTContract, address _newNFTContract) public onlyOwner {
        originNFTContract = _originNFTContract;
        newNFTContract = _newNFTContract;
    }

    function constructNewContract(uint256 start, uint256 end) public onlyOwner {
        require(currentAirDrops <= totalAirDrops, "Airdrop finished!");
        for (uint256 i = start; i < end; i++) {
            uint256 tokenId = ITContract(originNFTContract).tokenByIndex(i);
            address tokenOwner = ITContract(originNFTContract).ownerOf(tokenId);
            string memory uri = ITContract(originNFTContract).tokenURI(tokenId);
            ITContract(newNFTContract).freeMint(tokenOwner, tokenId, uri);
            currentAirDrops += 1;
        }
        
    }
}