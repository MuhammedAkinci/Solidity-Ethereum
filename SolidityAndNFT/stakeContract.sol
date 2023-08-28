// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// Library needed to use IERC20 token interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// Ownable contract containing functions callable only by the owner
import "@openzeppelin/contracts/access/Ownable.sol";

// NFT staking contract
contract NFTStaking is Ownable {
    // Reward token
    IERC20 public rewardToken;
    // Reward amount per second
    uint256 public rewardPerSecond;
    // Staking duration (in seconds)
    uint256 public stakingDuration;
    
    // User staking amounts
    mapping(address => uint256) public stakes;
    // Staking start times
    mapping(address => uint256) public startTimes;
    // Is the user enrolled in the program
    mapping(address => bool) public isEnrolled;

    // When creating the contract, reward token, reward amount per second, and staking duration are assigned
    constructor(address _rewardToken, uint256 _rewardPerSecond, uint256 _stakingDuration) {
        // Assign the reward token by converting to IERC20
        rewardToken = IERC20(_rewardToken);
        rewardPerSecond = _rewardPerSecond;
        stakingDuration = _stakingDuration;
    }

    // Marks the user as enrolled in the program
    function enroll() external {
        require(!isEnrolled[msg.sender], "Already enrolled");
        isEnrolled[msg.sender] = true;
    }

    // Function for staking
    function stake(uint256 _amount) external {
        require(isEnrolled[msg.sender], "Not enrolled"); // Checks if the user is enrolled
        require(_amount > 0, "Amount must be greater than 0");
        require(stakes[msg.sender] == 0, "Already staked");

        // Takes reward tokens from the user and records the staking amount
        rewardToken.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = _amount;
        startTimes[msg.sender] = block.timestamp;
    }

    // Function for unstaking
    function unstake() external {
        require(isEnrolled[msg.sender], "Not enrolled");
        require(stakes[msg.sender] > 0, "No staked amount");
        require(block.timestamp >= startTimes[msg.sender] + stakingDuration, "Staking duration not passed");

        // Calculates the reward and gives the reward and staked amount to the user
        uint256 reward = calculateReward(msg.sender);
        rewardToken.transfer(msg.sender, stakes[msg.sender] + reward);

        // Resets user's staking and start times
        stakes[msg.sender] = 0;
        startTimes[msg.sender] = 0;
    }

    // Calculates the reward for the user
    function calculateReward(address _user) public view returns (uint256) {
        if (block.timestamp < startTimes[_user] + stakingDuration) {
            uint256 stakedTime = block.timestamp - startTimes[_user];
            return (stakedTime * rewardPerSecond) * stakes[_user];
        }
        return (stakingDuration * rewardPerSecond) * stakes[_user];
    }

    // Function to update reward amount per second (callable only by owner)
    function updateRewardPerSecond(uint256 _newRewardPerSecond) external onlyOwner {
        rewardPerSecond = _newRewardPerSecond;
    }

    // Function to update staking duration (callable only by owner)
    function updateStakingDuration(uint256 _newStakingDuration) external onlyOwner {
        stakingDuration = _newStakingDuration;
    }

    // Function to withdraw reward tokens (callable only by owner)
    function withdrawRewardTokens(uint256 _amount) external onlyOwner {
        rewardToken.transfer(owner(), _amount);
    }
}
