// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// BurnStake contract
contract BurnStake is Ownable {
    IERC20 public rewardToken; // Reward token
    address public nftContractAddress; // Address of the NFTToken contract

    constructor(address _rewardToken, address _nftContractAddress) {
        rewardToken = IERC20(_rewardToken); // Set the address of the reward token
        nftContractAddress = _nftContractAddress; // Set the address of the NFTToken contract
    }

    function burnNFT(uint256 _id, address _student) external onlyOwner {
        INFTToken nftContract = INFTToken(nftContractAddress); // Use the interface to access the NFTToken contract
        nftContract.burnNFT(_id, _student); // Call the burn NFT function
    }
}

// Interface created for the NFTToken contract
interface INFTToken {
    function burnNFT(uint256 _id, address _student) external; // Define the burn NFT function
}
