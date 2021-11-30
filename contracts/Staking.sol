//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './ERC20Token.sol';
import "@openzeppelin/contracts/access/Ownable.sol";


contract Staking is ERC20Token, Ownable {

    struct StakingSummary {
        uint256 stake;
        uint256 lastClaimTime;
        uint256 rewards;
        uint256 previousRewards;
    }

    uint16 internal MinRewardPeriod = 3600;      // hour
    uint24 internal MinWithdrawPeriod = 86400;   // day
    uint256 internal MinStake = 10**decimals();

    mapping(address => StakingSummary) internal stakes;

    constructor(string memory name_, string memory symbol_, uint256 total)
    ERC20Token(name_, symbol_, total) {
    }

    function _transfer(address sender, address receiver, uint256 amount) internal override {
        require(balances[sender] >= amount, "transfer amount exceeds sender's balance");
        require(amount <= (balances[sender] - stakes[sender].stake), "transfer amount exceed available balance");

        balances[sender] -= amount;
        balances[receiver] += amount;

        emit Transfer(sender, receiver, amount);
    }

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function rewardsOf(address stakeholder, uint256 ClaimPeriod) internal view returns (uint256) {
        uint256 periods = ClaimPeriod/MinRewardPeriod;
        uint256 part = (MinRewardPeriod*periods) / 31556926;     // period/year
        uint256 reward = (part * yearRewardsOf(stakeholder));

        return reward + stakes[stakeholder].previousRewards;
    }

    function yearRewardsOf(address stakeholder) internal view returns (uint256) {
        return (stakes[stakeholder].stake * getInterest(stakes[stakeholder].stake)) / 100;
    }

    function getInterest(uint256 amount) internal view returns (uint8) {
        uint8 interest = 15;

        if (amount > 1500*MinStake) {
            interest = 18;
        } else if(amount > 1000*MinStake) {
            interest = 17;
        } else if(amount > 100*MinStake) {
            interest = 16;
        }

        return interest;
    }

    function getLastClaimPeriod() internal view returns (uint256) {
        return getCurrentTime() - stakes[msg.sender].lastClaimTime;
    }

    // staking implementation

    modifier ifHaveStake(address account) {
        require(stakes[account].stake != 0, "account doesn't have a stake");
        _;
    }

    function stake(uint256 amount) external {
        require(amount >= MinStake, "transfer amount less than minimum possible");
        require(balances[msg.sender] >= amount, "transfer amount exceeds sender's balance");

        if (stakes[msg.sender].stake == 0) {
            stakes[msg.sender].stake += amount;
        }
        else {
            require((balances[msg.sender] - stakes[msg.sender].stake) >= amount,
                "transfer amount exceeds available balance");
            stakes[msg.sender].previousRewards = rewardsOf(msg.sender, getLastClaimPeriod());
            stakes[msg.sender].stake += amount;
        }

        stakes[msg.sender].lastClaimTime = getCurrentTime();
    }

    function claim() public ifHaveStake(msg.sender) {
        stakes[msg.sender].rewards += rewardsOf(msg.sender, getLastClaimPeriod());
        stakes[msg.sender].previousRewards = 0;
        stakes[msg.sender].lastClaimTime = getCurrentTime();
    }

    function withdraw() external ifHaveStake(msg.sender) {
        require(getLastClaimPeriod() >= MinWithdrawPeriod,
            "current period less than minimum withdraw period (1 day)");

        mint(msg.sender, stakes[msg.sender].rewards);
        stakes[msg.sender].rewards = 0;
    }

    function claimAndWithdraw(uint256 amount) external ifHaveStake(msg.sender) {
        require(stakes[msg.sender].stake > amount, "withdraw amount exceeds stake");

        claim();
        stakes[msg.sender].stake -= amount;
    }

    function getStakeSummary() external view returns(StakingSummary memory) {
        return stakes[msg.sender];
    }
}
