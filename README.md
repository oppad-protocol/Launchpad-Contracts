# OPPAD - On-chain Presale, Token, and Farming Contracts

OPPAD is a suite of smart contracts designed for decentralized finance (DeFi) projects. It includes:
1. **Presale Contract**: A presale mechanism for launching new tokens.
2. **Token Contract**: An enhanced ERC-20 token with features like pausing, blacklisting, and tax mechanisms.
3. **Farming Contract**: A staking/farming contract for rewarding users who stake tokens.

These contracts are built on Ethereum using Solidity and are designed to be secure, modular, and easy to use.

---

## Table of Contents
1. [Contracts Overview](#contracts-overview)
2. [Installation](#installation)
3. [Usage](#usage)
   - [Presale Contract](#presale-contract)
   - [Token Contract](#token-contract)
   - [Farming Contract](#farming-contract)
4. [Contributing](#contributing)
5. [License](#license)

---

## Contracts Overview

### 1. Presale Contract
The **Presale Contract** allows users to create and participate in token presales. Key features include:
- Create presales with customizable parameters (e.g., token address, price, hard cap, soft cap, duration).
- Contribute ETH to the presale.
- Distribute tokens to contributors after the presale ends.
- Provide liquidity to decentralized exchanges (DEXs) after the presale.

### 2. Token Contract
The **Token Contract** is an enhanced ERC-20 token with additional features:
- Pausable transfers (owner can pause/unpause token transfers).
- Blacklist functionality (owner can blacklist/unblacklist addresses).
- Transfer tax (e.g., 2% tax on transfers, sent to a designated tax wallet).
- Snapshot functionality (owner can take snapshots of token balances).
- Permit functionality (EIP-2612 for gasless approvals).

### 3. Farming Contract
The **Farming Contract** allows users to stake tokens and earn rewards. Key features include:
- Stake tokens to earn rewards.
- Claim accumulated rewards.
- Unstake tokens to stop earning rewards.
- Admin functions to update reward rates and withdraw excess tokens.

---

## Installation

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- Hardhat or Truffle (for local development and testing)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/oppad-protocol/Launchpad-Contracts
   cd OPPAD
```

2. Install dependencies:

 ```bash
    Copy
    Edit
    npm install
 ```
3. Compile the contracts:


 ```bash
    Copy
    Edit
    npx hardhat compile
 ```
4. Run tests:


 ```bash
    Copy
    Edit
    npx hardhat test
```

# Usage
## Presale Contract
### Deploying the Contract

1. Deploy the presale contract:

```bash
    solidity
    Copy
    const PresaleContract = await ethers.getContractFactory("PresaleContract");
    const presale = await PresaleContract.deploy();
    await presale.deployed();
```
2. Create a presale:

```bash
    solidity
    Copy
    await presale.createPresale(
        tokenAddress,
        tokenPrice,
        hardCap,
        softCap,
        presaleDuration
    );
```
3. Contribute to the presale:
```bash
    solidity
    Copy
    await presale.contribute(presaleId, { value: ethers.utils.parseEther("1.0") });
```
4. Complete the presale:
```bash
    solidity
    Copy
    await presale.completePresale(presaleId);
```

# Token Contract
## Deploying the Contract
1. Deploy the token contract:
```bash
solidity
Copy
const MyToken = await ethers.getContractFactory("MyEnhancedToken");
const token = await MyToken.deploy("MyToken", "MTK", 1000000, taxWallet);
await token.deployed();
```
2. Mint tokens:
```bash
solidity
Copy
await token.mint(userAddress, ethers.utils.parseEther("1000"));
```
3. Pause/Unpause transfers:
```bash
solidity
Copy
await token.pause();
await token.unpause();
```
4. Blacklist/Unblacklist addresses:
```bash
solidity
Copy
await token.blacklist(userAddress);
await token.unblacklist(userAddress);
```

# Farming Contract
## Deploying the Contract

1. Deploy the farming contract:
```bash
solidity
Copy
const FarmingContract = await ethers.getContractFactory("FarmingContract");
const farming = await FarmingContract.deploy(stakingTokenAddress, rewardTokenAddress, rewardRate);
await farming.deployed();
```
2. Stake tokens:
```bash
solidity
Copy
await farming.stake(ethers.utils.parseEther("100"));
```
3. Claim rewards:
```bash
solidity
Copy
await farming.claimReward();
```
4. Unstake tokens:
```bash
solidity
Copy
await farming.unstake(ethers.utils.parseEther("50"));
```

## Contributing
### We welcome contributions to OPPAD! If you'd like to contribute, please follow these steps:

1. Fork the repository.

2. Create a new branch for your feature or bugfix.

3. Commit your changes and push to your fork.

4. Submit a pull request to the main branch.

5. Please ensure your code follows the project's coding standards and includes tests for new features.

## License
### OPPAD is licensed under the MIT License. See LICENSE for more details.

## Acknowledgments
1. OpenZeppelin for secure and audited smart contract libraries.

2. Hardhat for local development and testing.