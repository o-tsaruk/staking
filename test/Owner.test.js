const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Owner",  function () {
    let ownerAccount;
    let otherAccount;
    let Owner;
    let owner;

    beforeEach(async function () {
        [ownerAccount, otherAccount] = await ethers.getSigners();
        Owner = await ethers.getContractFactory("Owner");
        owner = await Owner.deploy();
        await owner.deployed();
    });

    describe("Change owner", function () {
        describe("When account isn't owner", function () {
            it("reverts", async function () {
                await expect(owner.connect(otherAccount).changeOwner(otherAccount.address))
                            .to.be.revertedWith("caller is not owner");
            });
        });

        describe("When account is owner", function () {
            it("Should change owner to otherAccount", async function () {
                await owner.changeOwner(otherAccount.address)
                await expect(await owner.getOwner()).to.equal(otherAccount.address);
            });
        });
    });

    describe("Get owner", function () {
        it("Should set the right owner", async function () {
            expect(await owner.getOwner()).to.equal(ownerAccount.address);
        });
    });

});
