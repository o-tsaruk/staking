//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


abstract contract Staking {

    struct StakingSummary {
        uint256 stake;
        uint256 creationTime;
        uint256 lastClaimTime;
        uint256 lastWithdrawTime;
        uint256 rewards;
        uint256 previousRewards;
    }

    uint16 internal minRewardPeriod = 3600;      // hour
    uint24 internal minWithdrawPeriod = 86400;   // day

    mapping(address => StakingSummary) internal stakes;

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function rewardsOf(address stakeholder) internal view returns (uint256) {
        uint256 periods = getLastClaimPeriod()/minRewardPeriod;
        uint256 part = (minRewardPeriod*periods)*1000000 / 31556926;     // period/year
        uint256 reward = (part * yearRewardsOf(stakeholder)) / 1000000;

        return reward + stakes[stakeholder].previousRewards;
    }

    function yearRewardsOf(address stakeholder) public view returns (uint256) {
        return (stakes[stakeholder].stake * getInterest(stakes[stakeholder].stake)) / 100;
    }

    function getInterest(uint256 amount) internal pure returns (uint8) {
        uint8 interest = 15;

        if (amount > 1500) {
            interest = 18;
        } else if(amount > 1000) {
            interest = 17;
        } else if(amount > 100) {
            interest = 16;
        }

        return interest;
    }

    function getLastClaimPeriod() internal view returns (uint256) {
        return getCurrentTime() - stakes[msg.sender].lastClaimTime;
    }

    function getLastWithdrawPeriod() internal view returns (uint256) {
        return getCurrentTime() - stakes[msg.sender].lastWithdrawTime;
    }

    function stake(uint256 amount) external virtual;

    function claim() public virtual;

    function withdraw() external virtual;

    function claimAndWithdraw(uint256 amount) external virtual;

    function getStakeSummary() external view returns(StakingSummary memory) {
        StakingSummary memory Stake = stakes[msg.sender];
        Stake.rewards = rewardsOf(msg.sender);
        return Stake;
    }

}