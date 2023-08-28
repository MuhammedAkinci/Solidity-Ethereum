// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// IERC20 token interfaceini kullanmak için gerekli kütüphane
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// Sadece sahibin çağırabileceği fonksiyonları içeren Ownable kontratı
import "@openzeppelin/contracts/access/Ownable.sol";

// NFT staking kontratı
contract NFTStaking is Ownable {
    // Ödül tokenı
    IERC20 public rewardToken;
    // Saniye başına ödül miktarı
    uint256 public rewardPerSecond;
    // Staking süresi (saniye cinsinden)
    uint256 public stakingDuration;
    
    // Kullanıcı staking miktarları
    mapping(address => uint256) public stakes;
    // Staking başlangıç zamanları
    mapping(address => uint256) public startTimes;
    // Kullanıcı eğitime kayıtlı mı
    mapping(address => bool) public isEnrolled;

    // Kontrat oluşturulurken ödül tokenı, ödül miktarı ve staking süresi atanır
    constructor(address _rewardToken, uint256 _rewardPerSecond, uint256 _stakingDuration) {
        // IERC20'ye dönüşüm yaparak ödül tokenı atanır
        rewardToken = IERC20(_rewardToken);
        rewardPerSecond = _rewardPerSecond;
        stakingDuration = _stakingDuration;
    }

    // Kullanıcıyı eğitime kaydolmuş olarak işaretler
    function enroll() external {
        require(!isEnrolled[msg.sender], "Already enrolled");
        isEnrolled[msg.sender] = true;
    }

    // Staking yapma fonksiyonu
    function stake(uint256 _amount) external {
        require(isEnrolled[msg.sender], "Not enrolled"); // Kullanıcının eğitime kayıtlı olup olmadığını kontrol eder
        require(_amount > 0, "Amount must be greater than 0");
        require(stakes[msg.sender] == 0, "Already staked");

        // Kullanıcıdan ödül tokenlarını alır ve staking miktarını kaydeder
        rewardToken.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = _amount;
        startTimes[msg.sender] = block.timestamp;
    }

    // Stakingi sonlandırma fonksiyonu
    function unstake() external {
        require(isEnrolled[msg.sender], "Not enrolled");
        require(stakes[msg.sender] > 0, "No staked amount");
        require(block.timestamp >= startTimes[msg.sender] + stakingDuration, "Staking duration not passed");

        // Ödülü hesaplar ve kullanıcıya ödülü ve staking miktarını verir
        uint256 reward = calculateReward(msg.sender);
        rewardToken.transfer(msg.sender, stakes[msg.sender] + reward);

        // Kullanıcının staking ve başlangıç zamanlarını sıfırlar
        stakes[msg.sender] = 0;
        startTimes[msg.sender] = 0;
    }

    // Kullanıcının alacağı ödülü hesaplar
    function calculateReward(address _user) public view returns (uint256) {
        if (block.timestamp < startTimes[_user] + stakingDuration) {
            uint256 stakedTime = block.timestamp - startTimes[_user];
            return (stakedTime * rewardPerSecond) * stakes[_user];
        }
        return (stakingDuration * rewardPerSecond) * stakes[_user];
    }

    // Sadece sahibin çağırabileceği ödül miktarını güncelleme fonksiyonu
    function updateRewardPerSecond(uint256 _newRewardPerSecond) external onlyOwner {
        rewardPerSecond = _newRewardPerSecond;
    }

    // Sadece sahibin çağırabileceği staking süresini güncelleme fonksiyonu
    function updateStakingDuration(uint256 _newStakingDuration) external onlyOwner {
        stakingDuration = _newStakingDuration;
    }

    // Sadece sahibin çağırabileceği ödül tokenlarını çekme fonksiyonu
    function withdrawRewardTokens(uint256 _amount) external onlyOwner {
        rewardToken.transfer(owner(), _amount);
    }
}
