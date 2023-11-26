// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract JobPortalContract{
    address public admin;
    uint256 public applicantIdCounter;
    uint256 public jobIdCounter;

    struct Applicant {
        string name;
        string applicantType;
        bool exists;

    }

    struct Job{
        string title;
        string description;
        uint256 jobId;
    }

    mapping(uint256 => Applicant) public applicants;  // Maps applicant ID to Applicant struct
    mapping(uint256 => Job) public jobs;  // Maps job ID to Job struct
    mapping(address => mapping(uint256 => bool)) public jobApplications;  // Maps applicant's address to a mapping of job IDs to application status
    mapping(address => mapping(uint256 => uint256)) public applicantRatings;   // Maps applicant's address to a mapping of applicant IDs to ratings

    // Contract constructor, sets the admin address and initializes counters
    constructor() {  
        admin = msg.sender;
        applicantIdCounter = 1;
        jobIdCounter = 1;
    }

    // Modifier to restrict access to only the admin
    modifier onlyAdmin{
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    // Modifier to check if an applicant with the given ID exists
    modifier applicantExists(uint256 applicantId) {
        require(applicants[applicantId].exists, "Applicant does not exist");
        _;
    }

    // Modifier to check if a job with the given ID exists
    modifier jobExists(uint256 jobId) {
        require(jobId <= jobIdCounter, "Job does not exist.");
        _;
    }

    // Modifier to check if an applicant has not already applied for a job
    modifier notAlreadyApplied(uint256 jobId) {
        require(!jobApplications[msg.sender][jobId], "You have already applied for this job.");
        _;
    }

    function addApplicant(string memory name, string memory applicantType) public onlyAdmin {
        uint256 applicantId = applicantIdCounter++;
        applicants[applicantId] = Applicant(name, applicantType, true);
    }

    function getApplicantDetails(uint256 applicantId) public view applicantExists(applicantId) returns (string memory, string memory ) {

        return (applicants[applicantId].name, applicants[applicantId].applicantType);
    }

    function addJob(string memory title, string memory description) public onlyAdmin {
        uint256 jobId = jobIdCounter++;
        jobs[jobId] = Job(title, description, jobId);
    }

    function getJobDetails(uint256 jobId) public view jobExists(jobId) returns (string memory, string memory) { 
        return (jobs[jobId].title, jobs[jobId].description);
    }

    function applyForJob(uint256 jobId) public jobExists(jobId) notAlreadyApplied(jobId) {
        jobApplications[msg.sender][jobId] = true;
    }

    function provideRating(uint256 applicantId, uint256 rating) public onlyAdmin applicantExists(applicantId) {
        applicantRatings[msg.sender][applicantId] = rating;
    }

    function fetchApplicantRating(uint256 applicantId) public view applicantExists(applicantId) returns (uint256) {
        return applicantRatings[msg.sender][applicantId];
    }

}