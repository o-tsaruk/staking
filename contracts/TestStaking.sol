//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './Staking.sol';

contract TestStaking is Staking {

    constructor(string memory name_, string memory symbol_, uint256 total)
    Staking(name_, symbol_, total) {
    }

    function changeMinWithdrawPeriod(uint24 period) public {
        MinWithdrawPeriod = period;
    }
}