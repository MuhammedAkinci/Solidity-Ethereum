pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTEducationPlatform is ERC721, Ownable {
    IERC20 public haqqToken;
    uint256 public requestCounter;

    mapping(uint256 => uint256) public courseStakeStartTime;
    mapping(uint256 => uint256) public courseStakeDuration;

    mapping(uint256 => address) public transferRequesters;
    mapping(uint256 => bool) public approvedTransferRequests;

    constructor(address _haqqTokenAddress) ERC721("NFTEducationCourse", "NFTEDU") {
        haqqToken = IERC20(_haqqTokenAddress);
        requestCounter = 1;
    }

    function mintCourse(address recipient, uint256 courseId) external onlyOwner {
        _mint(recipient, courseId);
    }

    function stakeCourse(uint256 courseId, uint256 duration) external onlyOwner {
        require(courseStakeStartTime[courseId] == 0, "Course is already staked");

        courseStakeStartTime[courseId] = block.timestamp;
        courseStakeDuration[courseId] = duration;
    }

    function completeCourse(uint256 courseId) external onlyOwner {
        require(courseStakeStartTime[courseId] > 0, "Course is not staked");
        require(block.timestamp >= courseStakeStartTime[courseId] + courseStakeDuration[courseId], "Course stake duration not passed");
    }

    function createTransferRequest(uint256 courseId) external {
        require(_exists(courseId), "Course does not exist");

        uint256 requestId = requestCounter;
        transferRequesters[requestId] = msg.sender;
        approvedTransferRequests[requestId] = false;
        requestCounter++;
    }

    function approveTransferRequest(uint256 requestId) external onlyOwner {
        require(approvedTransferRequests[requestId] == false, "Request already approved");

        approvedTransferRequests[requestId] = true;

        address requester = transferRequesters[requestId];

        _transfer(owner(), requester, requestId); // Transfer the NFT
    }

    function claimReward(uint256 courseId) external {
        require(ownerOf(courseId) != msg.sender, "Course owner cannot claim reward");
        require(courseStakeStartTime[courseId] > 0, "Course is not staked");
        require(block.timestamp >= courseStakeStartTime[courseId] + courseStakeDuration[courseId], "Course stake duration not passed");

        uint256 rewardAmount = calculateReward(courseStakeDuration[courseId]);
        courseStakeStartTime[courseId] = 0; // Reset stake details

        haqqToken.transfer(msg.sender, rewardAmount);
        _burn(courseId); // Burn the NFT after reward claim
    }

    function calculateReward(uint256 duration) internal pure returns (uint256) {
        // Implement your reward calculation logic here based on duration
        // This is just a placeholder
        return duration * 1000;
    }

    function getCourseStakeDetails(uint256 courseId) external view returns (uint256 startTime, uint256 duration) {
        startTime = courseStakeStartTime[courseId];
        duration = courseStakeDuration[courseId];
    }

    function getTransferRequestDetails(uint256 requestId) external view returns (address requester, bool isApproved) {
        requester = transferRequesters[requestId];
        isApproved = approvedTransferRequests[requestId];
    }

    function getApprovedTransferRequests() external view returns (uint256[] memory) {
        uint256[] memory approvedRequests;
        for (uint256 i = 1; i < requestCounter; i++) {
            if (approvedTransferRequests[i]) {
                approvedRequests[i] = i;
            }
        }
        return approvedRequests;
    }

    function getRewardAmount(uint256 courseId) external view returns (uint256) {
        if (courseStakeStartTime[courseId] == 0 || block.timestamp < courseStakeStartTime[courseId] + courseStakeDuration[courseId]) {
            return 0;
        }
        return calculateReward(courseStakeDuration[courseId]);
    }

    function getAllTransferRequests() external view returns (TransferRequest[] memory) {
        TransferRequest[] memory allRequests = new TransferRequest[](requestCounter - 1);

        for (uint256 i = 1; i < requestCounter; i++) {
            allRequests[i - 1] = TransferRequest({
                requestId: i,
                requester: transferRequesters[i],
                isApproved: approvedTransferRequests[i]
            });
        }

        return allRequests;
    }

    struct TransferRequest {
        uint256 requestId;
        address requester;
        bool isApproved;
    }
}