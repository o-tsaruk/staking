const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking", function () {

    beforeEach(async function () {
        [owner, user1] = await ethers.getSigners();
        const Token = await ethers.getContractFactory("Staking");
        [tokenName, tokenSymbol, initialBalance] = ["Staking", "STK", 5000000];
        const token = await Token.deploy(tokenName, tokenSymbol, initialBalance);
        await token.deployed();
    });

    // describe("stake", function () {
    //     it("Should be change balance", async function () {
    //         const initialOwnerBalance = await token.balanceOf(owner.address);
    //
    //         await token.stake(10);
    //         await token.stake(10);
    //         let ownerStake = await token.getStakeSummary();
    //         await expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance-10);
    //         await expect(ownerStake[0]).to.equal(10);
    //     });
    // });
    //
    // describe("Claim and withdraw", function () {
    //     it("Should fail if current period less than minimum claim period", async function () {
    //         await token.stake(100);
    //
    //         await expect(token.claim())
    //             .to.be.revertedWith("current period less than minimum reward period (1 hour)");
    //         await expect(token.claimAndWithdraw(1))
    //             .to.be.revertedWith("current period less than minimum reward period (1 hour)");
    //     });
    //
    //     it("Should withdraw if user didn't claim rewards for last hour ", async function () {
    //         const initialOwnerBalance = await token.balanceOf(owner.address);
    //         await token.stake(100);
    //         await token.withdraw();
    //
    //         await expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance);
    //     });
    // });
});