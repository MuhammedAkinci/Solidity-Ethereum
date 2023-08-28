pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTEducationPlatform is ERC721, Ownable {
    // Declare a variable to hold the Haqq token contract address
    IERC20 public haqqToken;
    // Counter to keep track of transfer request IDs
    uint256 public requestCounter;

    // Mapping to store the start time of staked courses
    mapping(uint256 => uint256) public courseStakeStartTime;
    // Mapping to store the duration of staked courses
    mapping(uint256 => uint256) public courseStakeDuration;

    // Mapping to store the requester of a transfer request
    mapping(uint256 => address) public transferRequesters;
    // Mapping to indicate whether a transfer request is approved
    mapping(uint256 => bool) public approvedTransferRequests;

    // Constructor that initializes the contract with the Haqq token address
    constructor(address _haqqTokenAddress) ERC721("NFTEducationCourse", "NFTEDU") {
        // Assign the Haqq token contract address
        haqqToken = IERC20(_haqqTokenAddress);
        // Initialize the request counter
        requestCounter = 1;
    }

    // Function to mint an NFT representing a course to a recipient
    function mintCourse(address recipient, uint256 courseId) external onlyOwner {
        _mint(recipient, courseId);
    }

    // Function to stake a course by setting its start time and duration
    function stakeCourse(uint256 courseId, uint256 duration) external onlyOwner {
        // Check if the course is not already staked
        require(courseStakeStartTime[courseId] == 0, "Course is already staked");

        // Set the start time and duration of the staked course
        courseStakeStartTime[courseId] = block.timestamp;
        courseStakeDuration[courseId] = duration;
    }

    // Function to mark a staked course as completed
    function completeCourse(uint256 courseId) external onlyOwner {
        // Check if the course is staked and its stake duration has passed
        require(courseStakeStartTime[courseId] > 0, "Course is not staked");
        require(block.timestamp >= courseStakeStartTime[courseId] + courseStakeDuration[courseId], "Course stake duration not passed");
    }

    // Function to create a transfer request for an NFT
    function createTransferRequest(uint256 courseId) external {
        // Check if the NFT/course exists
        require(_exists(courseId), "Course does not exist");

        // Generate a unique request ID
        uint256 requestId = requestCounter;
        // Record the requester and mark the request as unapproved
        transferRequesters[requestId] = msg.sender;
        approvedTransferRequests[requestId] = false;
        // Increment the request counter
        requestCounter++;
    }

    // Function to approve a transfer request and transfer the NFT
    function approveTransferRequest(uint256 requestId) external onlyOwner {
        // Check if the request is not already approved
        require(approvedTransferRequests[requestId] == false, "Request already approved");

        // Mark the request as approved
        approvedTransferRequests[requestId] = true;

        // Get the requester's address
        address requester = transferRequesters[requestId];

        // Transfer the NFT from the owner to the requester
        _transfer(owner(), requester, requestId);
    }

    // Function to claim a reward for completing a staked course
    function claimReward(uint256 courseId) external {
        // Check if the sender is not the owner of the course
        require(ownerOf(courseId) != msg.sender, "Course owner cannot claim reward");
        // Check if the course is staked and its stake duration has passed
        require(courseStakeStartTime[courseId] > 0, "Course is not staked");
        require(block.timestamp >= courseStakeStartTime[courseId] + courseStakeDuration[courseId], "Course stake duration not passed");

        // Calculate the reward amount based on the stake duration
        uint256 rewardAmount = calculateReward(courseStakeDuration[courseId]);
        // Reset the course stake details
        courseStakeStartTime[courseId] = 0;

        // Transfer the reward amount in Haqq tokens to the sender
        haqqToken.transfer(msg.sender, rewardAmount);
        // Burn the NFT representing the completed course
        _burn(courseId);
    }

    // Function to calculate the reward amount based on the stake duration
    function calculateReward(uint256 duration) internal pure returns (uint256) {
        // Implement your reward calculation logic here based on duration
        // This is just a placeholder
        return duration * 1000;
    }

    // Function to get the start time and duration of a staked course
    function getCourseStakeDetails(uint256 courseId) external view returns (uint256 startTime, uint256 duration) {
        startTime = courseStakeStartTime[courseId];
        duration = courseStakeDuration[courseId];
    }

    // Function to get the details of a transfer request
    function getTransferRequestDetails(uint256 requestId) external view returns (address requester, bool isApproved) {
        requester = transferRequesters[requestId];
        isApproved = approvedTransferRequests[requestId];
    }

    // Function to get the list of approved transfer requests
    function getApprovedTransferRequests() external view returns (uint256[] memory) {
        uint256[] memory approvedRequests;
        for (uint256 i = 1; i < requestCounter; i++) {
            if (approvedTransferRequests[i]) {
                approvedRequests[i] = i;
            }
        }
        return approvedRequests;
    }

    // Function to get the reward amount for completing a staked course
    function getRewardAmount(uint256 courseId) external view returns (uint256) {
        // Check if the course is not staked or the stake duration has not passed
        if (courseStakeStartTime[courseId] == 0 || block.timestamp < courseStakeStartTime[courseId] + courseStakeDuration[courseId]) {
            return 0;
        }
        // Calculate the reward amount based on the stake duration
        return calculateReward(courseStakeDuration[courseId]);
    }

    // Function to get the details of all transfer requests
    function getAllTransferRequests() external view returns (TransferRequest[] memory) {
        // Initialize an array to hold all transfer requests
        TransferRequest[] memory allRequests = new TransferRequest[](requestCounter - 1);

        // Iterate through all request IDs
        for (uint256 i = 1; i < requestCounter; i++) {
            // Populate the transfer request details into the array
            allRequests[i - 1] = TransferRequest({
                requestId: i,
                requester: transferRequesters[i],
                isApproved: approvedTransferRequests[i]
            });
        }

        return allRequests;
    }

    // Struct to store transfer request details
    struct TransferRequest {
        uint256 requestId;
        address requester;
        bool isApproved;
    }
}
