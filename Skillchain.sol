// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillChain {
    // Define structs for Job Seeker and Employer
    struct JobSeeker {
        string name;
        string[] degrees;
        bool registered;
    }
    
    struct Employer {
        string companyName;
        bool registered;
    }

    // Define a struct for Job
    struct Job {
        string jobTitle;
        string jobType;
        string requiredDegree;
        uint salary;
        address employer;
        address[] applicants; // Array to store the addresses of job applicants
    }

    // Mappings for storing job seekers, employers, and jobs
    mapping(address => JobSeeker) public jobSeekers;
    mapping(address => Employer) public employers;
    mapping(uint => Job) public jobs;
    
    // Track the job ID
    uint public jobCount;

    // Event definitions
    event JobSeekerRegistered(address indexed jobSeeker);
    event EmployerRegistered(address indexed employer);
    event JobPosted(uint jobId, address indexed employer);
    event JobApplied(uint jobId, address indexed jobSeeker);

    // Register a job seeker
    function registerJobSeeker(string memory _name, string[] memory _degrees) public {
        require(!jobSeekers[msg.sender].registered, "Job Seeker already registered.");
        
        jobSeekers[msg.sender] = JobSeeker({
            name: _name,
            degrees: _degrees,
            registered: true
        });

        emit JobSeekerRegistered(msg.sender);
    }

    // Register an employer
    function registerEmployer(string memory _companyName) public {
        require(!employers[msg.sender].registered, "Employer already registered.");
        
        employers[msg.sender] = Employer({
            companyName: _companyName,
            registered: true
        });

        emit EmployerRegistered(msg.sender);
    }

    // Post a job
    function postJob(string memory _jobTitle, string memory _jobType, string memory _requiredDegree, uint _salary) public {
        require(employers[msg.sender].registered, "Employer not registered.");
        
        // Create a new job with the provided details
        jobs[jobCount] = Job({
            jobTitle: _jobTitle,
            jobType: _jobType,
            requiredDegree: _requiredDegree,
            salary: _salary,
            employer: msg.sender,
            applicants: new address[](0)  // Initialize an empty array for applicants
        });

        emit JobPosted(jobCount, msg.sender);
        jobCount++;
    }

    // Apply for a job
    function applyForJob(uint _jobId) public {
        require(jobSeekers[msg.sender].registered, "Job Seeker not registered.");
        require(_jobId < jobCount, "Invalid job ID.");
        
        Job storage job = jobs[_jobId];
        
        // Check if job seeker's degree matches the required degree
        bool hasRequiredDegree = false;
        for (uint i = 0; i < jobSeekers[msg.sender].degrees.length; i++) {
            if (keccak256(abi.encodePacked(jobSeekers[msg.sender].degrees[i])) == keccak256(abi.encodePacked(job.requiredDegree))) {
                hasRequiredDegree = true;
                break;
            }
        }
        
        require(hasRequiredDegree, "Job Seeker does not have the required degree.");

        // Add job seeker to the list of applicants for the job
        job.applicants.push(msg.sender);

        emit JobApplied(_jobId, msg.sender);
    }

    // Get the list of applicants for a job
    function getJobApplicants(uint _jobId) public view returns (address[] memory) {
        require(_jobId < jobCount, "Invalid job ID.");
        require(jobs[_jobId].employer == msg.sender, "Only employer can access applicants.");
        return jobs[_jobId].applicants;
    }
}

