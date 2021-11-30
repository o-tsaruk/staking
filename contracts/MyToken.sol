//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './Stakeable.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Stakeable, Ownable {

    constructor(string memory name_, string memory symbol_, uint256 InitialAmount) ERC20(name_, symbol_) {
        _mint(msg.sender, InitialAmount);
    }

    modifier ifBalanceAvailable(address account, uint256 amount) {
        require(amount <= (balanceOf(account) - stakes[account].stake),
            "transfer amount exceed available balance");
        _;
    }

    function _transfer(address sender, address receiver, uint256 amount) internal override ifBalanceAvailable(sender, amount) {
        require(balanceOf(sender) >= amount, "transfer amount exceeds sender's balance");

        _mint(sender, amount);
        _burn(receiver, amount);

        emit Transfer(sender, receiver, amount);
    }

    function myTokenStake(uint256 amount) external ifBalanceAvailable(msg.sender, amount) {
        require(amount >= MinStake, "transfer amount less than minimum possible");
        stake(amount);
    }

    function myTokenWithdraw() external {
        withdraw();
        _mint(msg.sender, stakes[msg.sender].rewards + stakes[msg.sender].previousRewards);

        if (stakes[msg.sender].WithdrawAmount != 0) {
            stakes[msg.sender].stake -= stakes[msg.sender].WithdrawAmount;
            stakes[msg.sender].WithdrawAmount = 0;
        }
        stakes[msg.sender].rewards = 0;
        stakes[msg.sender].previousRewards = 0;
    }
}