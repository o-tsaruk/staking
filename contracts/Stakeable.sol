//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Stakeable {

    struct StakingSummary {
        uint256 stake;
        uint256 lastClaimTime;
        uint256 WithdrawAmount;
        uint256 rewards;
        uint256 previousRewards;
    }

    uint16 internal MinRewardPeriod = 3600;      // hour
    uint24 internal MinWithdrawPeriod = 86400;   // day
    uint256 internal MinStake = (10**6);

    mapping(address => StakingSummary) internal stakes;

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function currentRewards(address stakeholder, uint256 ClaimPeriod) public view returns (uint256) {
        uint256 periods = ClaimPeriod/MinRewardPeriod;
        uint256 part = (MinRewardPeriod*periods)*(10**6) / 31556926;     // period/year
        uint256 reward = (part * yearRewardsOf(stakeholder))/(10**6);

        return reward;
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

    function getLastClaimPeriod() public view returns (uint256) {
        return getCurrentTime() - stakes[msg.sender].lastClaimTime;
    }

    // staking implementation

    modifier ifHaveStake(address account) {
        require(stakes[account].stake != 0, "account doesn't have a stake");
        _;
    }

    function stake(uint256 amount) internal {
        if (stakes[msg.sender].stake == 0) {
            stakes[msg.sender].stake += amount;
        }
        else {
            stakes[msg.sender].previousRewards += currentRewards(msg.sender, getLastClaimPeriod());
            stakes[msg.sender].stake += amount;
        }

        stakes[msg.sender].lastClaimTime = getCurrentTime();
    }

    function claim() public ifHaveStake(msg.sender) {
        stakes[msg.sender].rewards += currentRewards(msg.sender, getLastClaimPeriod());
        stakes[msg.sender].previousRewards = 0;
        stakes[msg.sender].lastClaimTime = getCurrentTime();
    }

    function withdraw() internal view ifHaveStake(msg.sender) {
        require(getLastClaimPeriod() >= MinWithdrawPeriod,
            "current period less than minimum withdraw period (1 day)");
    }

    function claimAndWithdraw(uint256 amount) external ifHaveStake(msg.sender) {
        require(stakes[msg.sender].stake > amount, "withdraw amount exceeds stake");

        claim();
        stakes[msg.sender].WithdrawAmount += amount;
    }

    function getStakeSummary() external view returns(StakingSummary memory) {
        return stakes[msg.sender];
    }
}
