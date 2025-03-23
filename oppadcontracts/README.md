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
   git clone https://github.com/your-username/OPPAD.git
   cd OPPAD