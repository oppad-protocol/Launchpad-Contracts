// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import OpenZeppelin contracts using raw URLs (v4.8.0)
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.8.0/contracts/token/ERC20/IERC20.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.8.0/contracts/security/ReentrancyGuard.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.8.0/contracts/access/Ownable.sol";

contract HAWStaking is Ownable, ReentrancyGuard {
    IERC20 public stakingToken; // Your HAW token

    // Duration constants (in seconds)
    uint256 public constant DURATION_1W = 7 days;
    uint256 public constant DURATION_3M = 90 days;   // approximate
    uint256 public constant DURATION_6M = 180 days;  // approximate
    uint256 public constant DURATION_1Y = 365 days;  // approximate

    // Reward percentages (in percent)
    uint256 public constant REWARD_1W = 8;
    uint256 public constant REWARD_3M = 12;
    uint256 public constant REWARD_6M = 33;
    uint256 public constant REWARD_1Y = 66;

    // Penalty rate for early unstaking: 5%
    uint256 public constant PENALTY_RATE = 5;
    // Penalty wallet (and owner for withdrawn funds) - must be payable.
    address payable public tWallet = payable(0xc13530F2D2317aa1E4A6601122432Bf3eED9E755);
    // A flag to indicate if trading is active.
    bool public tradingOpen = true;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        uint256 rewardPercent;
        bool unstaked;
        bool rewardClaimed;
    }

    mapping(address => Stake[]) public stakes;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 duration,
        uint256 rewardPercent,
        uint256 stakeIndex
    );
    event Unstaked(
        address indexed user,
        uint256 stakeIndex,
        uint256 amountReturned
    );
    event RewardClaimed(
        address indexed user,
        uint256 stakeIndex,
        uint256 reward
    );

   
    constructor(address _stakingToken) {
        require(_stakingToken != address(0), "Invalid token address");
        stakingToken = IERC20(_stakingToken);
    }

  
    function stake(uint256 amount, uint8 option) external nonReentrant {
        require(amount > 0, "Cannot stake 0 tokens");
        require(option >= 1 && option <= 4, "Invalid staking option");

        uint256 duration;
        uint256 rewardPercent;

        if (option == 1) {
            duration = DURATION_1W;
            rewardPercent = REWARD_1W;
        } else if (option == 2) {
            duration = DURATION_3M;
            rewardPercent = REWARD_3M;
        } else if (option == 3) {
            duration = DURATION_6M;
            rewardPercent = REWARD_6M;
        } else if (option == 4) {
            duration = DURATION_1Y;
            rewardPercent = REWARD_1Y;
        }

        // Transfer tokens from the user to the staking contract.
        require(
            stakingToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        Stake memory newStake = Stake({
            amount: amount,
            startTime: block.timestamp,
            duration: duration,
            rewardPercent: rewardPercent,
            unstaked: false,
            rewardClaimed: false
        });

        stakes[msg.sender].push(newStake);
        uint256 stakeIndex = stakes[msg.sender].length - 1;
        emit Staked(msg.sender, amount, duration, rewardPercent, stakeIndex);
    }

   
    function unstake(uint256 stakeIndex) external nonReentrant {
        require(stakeIndex < stakes[msg.sender].length, "Invalid stake index");
        Stake storage userStake = stakes[msg.sender][stakeIndex];
        require(!userStake.unstaked, "Stake already unstaked");

        uint256 stakedAmount = userStake.amount;
        uint256 endTime = userStake.startTime + userStake.duration;
        uint256 amountToReturn;

        if (block.timestamp < endTime) {
            // Early unstake: apply a 5% penalty.
            uint256 penalty = (stakedAmount * PENALTY_RATE) / 100;
            amountToReturn = stakedAmount - penalty;
            // Transfer the penalty to the designated penalty wallet.
            require(
                stakingToken.transfer(tWallet, penalty),
                "Penalty transfer failed"
            );
        } else {
            amountToReturn = stakedAmount;
        }

        userStake.unstaked = true;
        require(
            stakingToken.transfer(msg.sender, amountToReturn),
            "Return transfer failed"
        );
        emit Unstaked(msg.sender, stakeIndex, amountToReturn);
    }

  
    function claimReward(uint256 stakeIndex) external nonReentrant {
        require(stakeIndex < stakes[msg.sender].length, "Invalid stake index");
        Stake storage userStake = stakes[msg.sender][stakeIndex];
        require(!userStake.rewardClaimed, "Reward already claimed");
        require(
            block.timestamp >= userStake.startTime + userStake.duration,
            "Staking period not ended"
        );

        // Reward = staked amount * rewardPercent / 100.
        uint256 reward = (userStake.amount * userStake.rewardPercent) / 100;
        userStake.rewardClaimed = true;
        require(
            stakingToken.transfer(msg.sender, reward),
            "Reward transfer failed"
        );
        emit RewardClaimed(msg.sender, stakeIndex, reward);
    }

  
    function getStakes(address account)
        external
        view
        returns (
            uint256[] memory indices,
            uint256[] memory amounts,
            uint256[] memory startTimes,
            uint256[] memory durations,
            uint256[] memory rewardPercents,
            bool[] memory unstakedFlags,
            bool[] memory rewardClaimedFlags
        )
    {
        uint256 count = stakes[account].length;
        indices = new uint256[](count);
        amounts = new uint256[](count);
        startTimes = new uint256[](count);
        durations = new uint256[](count);
        rewardPercents = new uint256[](count);
        unstakedFlags = new bool[](count);
        rewardClaimedFlags = new bool[](count);

        for (uint256 i = 0; i < count; i++) {
            indices[i] = i;
            Stake storage s = stakes[account][i];
            amounts[i] = s.amount;
            startTimes[i] = s.startTime;
            durations[i] = s.duration;
            rewardPercents[i] = s.rewardPercent;
            unstakedFlags[i] = s.unstaked;
            rewardClaimedFlags[i] = s.rewardClaimed;
        }
    }

   
    function withdrawTokens(address _token, uint256 amount) external onlyOwner {
        require(IERC20(_token).transfer(owner(), amount), "Token transfer failed");
    }

  
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner()).transfer(balance);
    }

 
    function clearStuckETH() external onlyOwner returns (bool) {
        require(tradingOpen, "Trading not active; cannot clear ETH");
        uint256 contractETH = address(this).balance;
        if (contractETH > 0) {
            tWallet.transfer(contractETH);
        }
        return true;
    }
}
