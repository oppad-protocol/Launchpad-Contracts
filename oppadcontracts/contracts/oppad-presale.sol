// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PresaleContract is ReentrancyGuard {
    struct Presale {
        address tokenAddress;
        uint256 tokenPrice; // Price per token in wei
        uint256 hardCap; // Maximum ETH to be raised
        uint256 softCap; // Minimum ETH to be raised
        uint256 presaleStartTime;
        uint256 presaleEndTime;
        uint256 totalRaised;
        bool isCompleted;
    }

    mapping(uint256 => Presale) public presales;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    uint256 public presaleCount;

    event PresaleCreated(uint256 presaleId, address tokenAddress, uint256 tokenPrice, uint256 hardCap, uint256 softCap, uint256 presaleDuration);
    event Contributed(uint256 presaleId, address contributor, uint256 amount);
    event PresaleCompleted(uint256 presaleId, uint256 totalRaised);
    event TokensClaimed(uint256 presaleId, address contributor, uint256 tokenAmount);

    // Create a new presale
    function createPresale(
        address _tokenAddress,
        uint256 _tokenPrice,
        uint256 _hardCap,
        uint256 _softCap,
        uint256 _presaleDuration
    ) external {
        require(_tokenAddress != address(0), "Invalid token address");
        require(_tokenPrice > 0, "Token price must be greater than 0");
        require(_hardCap > _softCap, "Hard cap must be greater than soft cap");

        presaleCount++;
        presales[presaleCount] = Presale({
            tokenAddress: _tokenAddress,
            tokenPrice: _tokenPrice,
            hardCap: _hardCap,
            softCap: _softCap,
            presaleStartTime: block.timestamp,
            presaleEndTime: block.timestamp + _presaleDuration,
            totalRaised: 0,
            isCompleted: false
        });

        emit PresaleCreated(presaleCount, _tokenAddress, _tokenPrice, _hardCap, _softCap, _presaleDuration);
    }

    // Contribute ETH to a presale
    function contribute(uint256 _presaleId) external payable nonReentrant {
        Presale storage presale = presales[_presaleId];
        require(block.timestamp >= presale.presaleStartTime, "Presale not started");
        require(block.timestamp <= presale.presaleEndTime, "Presale ended");
        require(presale.totalRaised + msg.value <= presale.hardCap, "Hard cap reached");

        presale.totalRaised += msg.value;
        contributions[_presaleId][msg.sender] += msg.value;

        emit Contributed(_presaleId, msg.sender, msg.value);
    }

    // Complete the presale and distribute tokens
    function completePresale(uint256 _presaleId) external nonReentrant {
        Presale storage presale = presales[_presaleId];
        require(block.timestamp > presale.presaleEndTime, "Presale not ended");
        require(!presale.isCompleted, "Presale already completed");
        require(presale.totalRaised >= presale.softCap, "Soft cap not reached");

        presale.isCompleted = true;

        // Calculate the total tokens to distribute
        uint256 totalTokens = presale.totalRaised / presale.tokenPrice;

        // Transfer tokens from the presale creator to this contract
        IERC20(presale.tokenAddress).transferFrom(msg.sender, address(this), totalTokens);

        emit PresaleCompleted(_presaleId, presale.totalRaised);
    }

    // Allow contributors to claim their tokens after the presale is completed
    function claimTokens(uint256 _presaleId) external nonReentrant {
        Presale storage presale = presales[_presaleId];
        require(presale.isCompleted, "Presale not completed");

        uint256 contributionAmount = contributions[_presaleId][msg.sender];
        require(contributionAmount > 0, "No contribution found");

        // Calculate the token amount based on the contribution
        uint256 tokenAmount = (contributionAmount * 1e18) / presale.tokenPrice;

        // Reset the contribution to prevent reentrancy
        contributions[_presaleId][msg.sender] = 0;

        // Transfer tokens to the contributor
        IERC20(presale.tokenAddress).transfer(msg.sender, tokenAmount);

        emit TokensClaimed(_presaleId, msg.sender, tokenAmount);
    }

    // Add liquidity to a DEX (e.g., Uniswap) - This is a placeholder function
    function addLiquidity(uint256 _presaleId, address _routerAddress) external {
        Presale storage presale = presales[_presaleId];
        require(presale.isCompleted, "Presale not completed");

        // Example: Use 50% of the raised ETH for liquidity
        uint256 ethAmount = presale.totalRaised / 2;
        uint256 tokenAmount = (ethAmount * 1e18) / presale.tokenPrice;

        // Approve the router to spend tokens
        IERC20(presale.tokenAddress).approve(_routerAddress, tokenAmount);

        // Add liquidity (this is a simplified example)
        // You need to implement the actual logic for adding liquidity to the DEX
    }

    // Allow the contract owner to withdraw unsold tokens
    function withdrawUnsoldTokens(uint256 _presaleId) external {
        Presale storage presale = presales[_presaleId];
        require(presale.isCompleted, "Presale not completed");

        uint256 unsoldTokens = IERC20(presale.tokenAddress).balanceOf(address(this));
        IERC20(presale.tokenAddress).transfer(msg.sender, unsoldTokens);
    }
}