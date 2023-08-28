// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTToken is ERC1155, Ownable {
    // IDs represent types of education
    uint256 public constant COURSE = 0;
    uint256 public constant WORKSHOP = 1;

    // Addresses and information for education types
    mapping(uint256 => mapping(bytes32 => bool)) public students;
    mapping(uint256 => mapping(address => address)) public instructorsAddresses;
    mapping(uint256 => mapping(address => string)) public courseInfo;

    // Instructor accounts
    mapping(address => uint256) public instructorBalances;

    // Education fee rate (between 0 and 100)
    uint256 public commissionRate = 10; // 10% commission rate

    constructor() ERC1155("https://your-api-url/{id}.json") {
        // The contract owner is set as the owner of Ownable
        transferOwnership(msg.sender);
    }

    // Creates a new education
    function createCourse(uint256 _id, address _instructor, address _student, string memory _courseInfo) public onlyOwner {
        require(_instructor != address(0), "Invalid instructor address");
        require(_student != address(0), "Invalid student address");

        bytes32 studentKey = keccak256(abi.encodePacked(_student)); // Create a unique key from student address

        instructorsAddresses[_id][_instructor] = _instructor;
        students[_id][studentKey] = true; // Set to true when a student is enrolled
        courseInfo[_id][_student] = _courseInfo;

        _mint(_instructor, _id, 1, "");
        _mint(_student, _id, 1, "");
    }

    // Updates education information
    function updateCourseInfo(uint256 _id, string memory _newCourseInfo) public {
        address student = msg.sender;
        bytes32 studentKey = keccak256(abi.encodePacked(student)); // Create a key from student address
        require(students[_id][studentKey], "Not enrolled in the course"); // Check the boolean value using control

        courseInfo[_id][student] = _newCourseInfo;
    }

    // Calculates the commission fee for education
    function calculateCommission(uint256 _amount) internal view returns (uint256) {
        return (_amount * commissionRate) / 100;
    }

    // Sends commission fee to instructor's account
    function sendCommission(address _instructor, uint256 _amount) internal {
        uint256 commissionAmount = calculateCommission(_amount);
        instructorBalances[_instructor] += commissionAmount;
    }

    // Withdraws commission from instructor's account
    function withdrawCommission() public {
        address instructor = msg.sender;
        uint256 balance = instructorBalances[instructor];
        require(balance > 0, "No commission to withdraw");

        instructorBalances[instructor] = 0;
        payable(instructor).transfer(balance);
    }

    // Inherits functions from ERC1155 standard
    function uri(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(_id), uint2str(_id)));
    }

    // Helper function to convert uint256 to string
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        return string(bstr);
    }
}
