// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// BurnStake kontratı
contract BurnStake is Ownable {
    IERC20 public rewardToken; // Ödül tokenı
    address public nftContractAddress; // NFTToken kontratının adresi

    constructor(address _rewardToken, address _nftContractAddress) {
        rewardToken = IERC20(_rewardToken); // Ödül tokenının adresini belirle
        nftContractAddress = _nftContractAddress; // NFTToken kontratının adresini belirle
    }

    function burnNFT(uint256 _id, address _student) external onlyOwner {
        INFTToken nftContract = INFTToken(nftContractAddress); // NFTToken kontratına erişim için arayüzü kullan
        nftContract.burnNFT(_id, _student); // NFT'yi yakma fonksiyonunu çağır
    }
}

    // NFTToken kontratı için oluşturulan arayüz
    interface INFTToken {
        function burnNFT(uint256 _id, address _student) external; // NFT'yi yakma fonksiyonunu tanımla
    }
