const { expect } = require("chai");
const { network, ethers } = require("hardhat");

describe("Staking", function () {
    let owner;
    let user;
    let tokenName;
    let tokenSymbol;
    let initialBalance;
    let token;
    const day = 86400;

    beforeEach(async function () {
        [owner, user] = await ethers.getSigners();
        const Token = await ethers.getContractFactory("MyToken");
        [tokenName, tokenSymbol, initialBalance] = ["Staking", "STK", 110000000];
        token = await Token.deploy(tokenName, tokenSymbol, initialBalance);
        await token.deployed();
    });

    describe("Stake", function () {
        it("Should be change stake balance and previous rewards", async function () {
            const initialOwnerBalance = await token.balanceOf(owner.address);

            await token.myTokenStake(1000000);
            await network.provider.send("evm_increaseTime", [day])
            await token.myTokenStake(2000000);
            let StakeSummary = await token.getStakeSummary();

            await expect(StakeSummary[0]).to.equal(3000000);
            await expect(StakeSummary[4]).to.equal(410);
            await expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance);
        });

        it("Should fail if amount less than minimum possible", async function () {
            await expect(token.myTokenStake(1)).to.be.revertedWith(
                                                "transfer amount less than minimum possible");
        });
    });

    describe("Claim and withdraw", function () {
        it("Should change withdraw amount and rewards", async function () {
            await token.myTokenStake(1000000);
            await network.provider.send("evm_increaseTime", [day]);
            await token.myTokenStake(1000000);
            await network.provider.send("evm_increaseTime", [day]);
            await token.claimAndWithdraw(100000);
            let StakeSummary = await token.getStakeSummary();

            await expect(StakeSummary[2]).to.equal(100000);
            await expect(StakeSummary[3]).to.equal(821);
        });

        it("Should give 16% rewards instead of 15% rewards", async function () {
            await token.myTokenStake(110000000);

            await network.provider.send("evm_increaseTime", [day]);
            await token.claim();
            let StakeSummary = await token.getStakeSummary();

            await expect(StakeSummary[3]).to.equal(48171);
        })

        it("Should fail if withdraw amount exceeds stake", async function () {
            await token.myTokenStake(1000000);
            await expect(token.claimAndWithdraw(1000001)).to.be.revertedWith("withdraw amount exceeds stake");
        });

        it("Should fail if account doesn't have a stake", async function () {
            await expect(token.claimAndWithdraw(1000000)).to.be.revertedWith("account doesn't have a stake");
        });
    });

    describe("Withdraw", function () {
        it("Should revert if MinWithdrawPeriod isn't over, otherwise withdraw", async function () {
            const initialOwnerBalance = await token.balanceOf(owner.address);
            await token.myTokenStake(1000000);
            await network.provider.send("evm_increaseTime", [day]);

            await token.claim();
            await expect(token.myTokenWithdraw()).to.be.revertedWith(
                    "current period less than minimum withdraw period (1 day)");

            await network.provider.send("evm_increaseTime", [day]);
            await token.myTokenWithdraw();

            await expect(await token.balanceOf(owner.address)).to.equal(Number(initialOwnerBalance)+410);
        });
    });
});