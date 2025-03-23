// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract MyEnhancedToken is ERC20, Ownable, Pausable, ERC20Snapshot, ERC20Permit {
    uint256 public constant TAX_RATE = 200; // 2% tax rate (200 basis points)
    address public taxWallet; // Wallet to receive tax

    mapping(address => bool) public isBlacklisted; // Blacklist for addresses

    event TaxWalletUpdated(address newTaxWallet);
    event Blacklisted(address account);
    event Unblacklisted(address account);

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _taxWallet
    ) ERC20(name, symbol) ERC20Permit(name) {
        require(_taxWallet != address(0), "Tax wallet cannot be zero address");
        taxWallet = _taxWallet;
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // Override transfer to include tax and blacklist checks
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        require(!isBlacklisted[msg.sender], "Sender is blacklisted");
        require(!isBlacklisted[to], "Recipient is blacklisted");

        uint256 tax = (amount * TAX_RATE) / 10000;
        uint256 netAmount = amount - tax;

        _transfer(msg.sender, taxWallet, tax); // Send tax to tax wallet
        _transfer(msg.sender, to, netAmount); // Send net amount to recipient

        return true;
    }

    // Override transferFrom to include tax and blacklist checks
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        require(!isBlacklisted[from], "Sender is blacklisted");
        require(!isBlacklisted[to], "Recipient is blacklisted");

        uint256 tax = (amount * TAX_RATE) / 10000;
        uint256 netAmount = amount - tax;

        _transfer(from, taxWallet, tax); // Send tax to tax wallet
        _transfer(from, to, netAmount); // Send net amount to recipient

        _approve(from, msg.sender, allowance(from, msg.sender) - amount);
        return true;
    }

    // Mint new tokens (only callable by the owner)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Burn tokens (anyone can burn their own tokens)
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // Allow the owner to burn tokens from any address
    function burnFrom(address account, uint256 amount) external onlyOwner {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }

    // Pause token transfers (only callable by the owner)
    function pause() external onlyOwner {
        _pause();
    }

    // Unpause token transfers (only callable by the owner)
    function unpause() external onlyOwner {
        _unpause();
    }

    // Blacklist an address (only callable by the owner)
    function blacklist(address account) external onlyOwner {
        isBlacklisted[account] = true;
        emit Blacklisted(account);
    }

    // Remove an address from the blacklist (only callable by the owner)
    function unblacklist(address account) external onlyOwner {
        isBlacklisted[account] = false;
        emit Unblacklisted(account);
    }

    // Update the tax wallet (only callable by the owner)
    function updateTaxWallet(address newTaxWallet) external onlyOwner {
        require(newTaxWallet != address(0), "Tax wallet cannot be zero address");
        taxWallet = newTaxWallet;
        emit TaxWalletUpdated(newTaxWallet);
    }

    // Take a snapshot of token balances (only callable by the owner)
    function snapshot() external onlyOwner {
        _snapshot();
    }

    // Override _beforeTokenTransfer to include snapshot logic
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}