// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FarmingContract is ReentrancyGuard, Ownable {
    IERC20 public stakingToken; // Token to be staked
    IERC20 public rewardToken; // Token to be rewarded

    uint256 public rewardRate; // Reward rate per second per token staked
    uint256 public totalStaked; // Total tokens staked
    uint256 public lastUpdateTime; // Last time rewards were calculated
    uint256 public rewardPerTokenStored; // Accumulated rewards per token

    mapping(address => uint256) public stakedBalances; // Staked balances of users
    mapping(address => uint256) public userRewardPerTokenPaid; // Rewards paid per token for each user
    mapping(address => uint256) public rewards; // Rewards earned by each user

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRate);

    constructor(address _stakingToken, address _rewardToken, uint256 _rewardRate) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
    }

    // Update rewards for a user
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    // Calculate rewards per token staked
    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / totalStaked;
    }

    // Calculate earned rewards for a user
    function earned(address account) public view returns (uint256) {
        return (stakedBalances[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18 + rewards[account];
    }

    // Stake tokens
    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");

        totalStaked += amount;
        stakedBalances[msg.sender] += amount;

        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    // Unstake tokens
    function unstake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot unstake 0");
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");

        totalStaked -= amount;
        stakedBalances[msg.sender] -= amount;

        stakingToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    // Claim rewards
    function claimReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }

    // Update reward rate (only callable by the owner)
    function setRewardRate(uint256 newRate) external onlyOwner {
        rewardRate = newRate;
        emit RewardRateUpdated(newRate);
    }

    // Withdraw excess reward tokens (only callable by the owner)
    function withdrawExcessRewards(uint256 amount) external onlyOwner {
        rewardToken.transfer(owner(), amount);
    }
}