const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20 token standard", function () {
    let owner;
    let user1;
    let user2;
    let Token;
    let token;
    let tokenName;
    let tokenSymbol;
    let initialBalance;
    const zeroAccount = "0x0000000000000000000000000000000000000000";

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();
        Token = await ethers.getContractFactory("ERC20Token");
        [tokenName, tokenSymbol, initialBalance] = ["ERC20staking", "STK", 1600];
        token = await Token.deploy(tokenName, tokenSymbol, initialBalance);
        await token.deployed();
    });

    describe("Deployment", function () {
        it("Should set the right name of contract", async function () {
            expect(await token.name()).to.equal(tokenName);
        });

        it("Should set the right symbol of contract", async function () {
            expect(await token.symbol()).to.equal(tokenSymbol);
        });

        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await token.balanceOf(owner.address);
            expect(await token.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Transactions", function() {
        describe("Transfer", function () {
            it("Should fail if receive is zero address", async function () {
                await expect(token.transfer(zeroAccount, 1)).to.be.revertedWith("transfer to the zero address");
            });

            it("Should transfer tokens between accounts", async function () {
                await token.transfer(user1.address, 100);
                const user1Balance = await token.balanceOf(user1.address);
                expect(user1Balance).to.equal(100);

                await token.connect(user1).transfer(user2.address, 50);
                const user2Balance = await token.balanceOf(user2.address);
                expect(user2Balance).to.equal(50);
            });

            it("Should fail if sender doesn’t have enough tokens", async function () {
                const initialOwnerBalance = await token.balanceOf(owner.address);

                await expect(token.connect(user1).transfer(owner.address, 1))
                    .to.be.revertedWith("transfer amount exceeds sender's balance");

                expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance);
            });

            it("Should update balances after transfers", async function () {
                const initialOwnerBalance = await token.balanceOf(owner.address);

                await token.transfer(user1.address, 100);
                await token.transfer(user2.address, 200);

                const resultOwnerBalance = await token.balanceOf(owner.address);
                expect(resultOwnerBalance).to.equal(initialOwnerBalance - 300);

                const user1Balance = await token.balanceOf(user1.address);
                expect(user1Balance).to.equal(100);

                const user2Balance = await token.balanceOf(user2.address);
                expect(user2Balance).to.equal(200);
            });
        });

        describe("TransferFrom", function () {
            describe("Zero addresses", function () {
                it("Should fail if sender is zero address", async function () {
                    await expect(token.transferFrom(zeroAccount, user1.address, 1))
                        .to.be.revertedWith("transfer from the zero address");
                });

                it("Should fail if receiver is zero address", async function () {
                    await expect(token.transferFrom(owner.address, zeroAccount, 1))
                        .to.be.revertedWith("transfer to the zero address");
                });
            });

            describe("When message sender have not enough allowance", function () {
                it("Should fail", async function () {
                    await expect(token.transferFrom(owner.address, user1.address, 100))
                        .to.be.revertedWith("transfer amount exceeds allowance");
                });
            });

            describe("When message sender have enough allowance", function () {
                it("Should transfer tokens between accounts", async function () {
                    const initialOwnerBalance = await token.balanceOf(owner.address);

                    await token.transfer(user1.address, 10);
                    await token.connect(user1).increaseAllowance(owner.address, 10);
                    await token.transferFrom(user1.address, user2.address, 10);

                    await expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance-10);
                    await expect(await token.balanceOf(user2.address)).to.equal(10);
                });
            });
        });
    });

    describe("Change allowance", function () {
        it("Should increase allowance", async function () {
            await token.increaseAllowance(user1.address, 30);
            await expect(await token.allowance(owner.address,user1.address)).to.equal(30);
        });

        it("Should fail if subtracted amount exceeds allowance", async function () {
            await expect(token.decreaseAllowance(user1.address, 30))
                .to.be.revertedWith("subtracted amount exceeds current allowance");
        });

        it("Should decrease allowance", async function () {
            await token.increaseAllowance(user1.address, 30);
            await token.decreaseAllowance(user1.address, 10);
            await expect(await token.allowance(owner.address,user1.address)).to.equal(20);
        });

        describe("If spender is the zero address", function () {
            it("Should fail", async function () {
                await expect(token.increaseAllowance(zeroAccount, 1))
                    .to.be.revertedWith("approve to the zero address");
            });
        });
    });
});
