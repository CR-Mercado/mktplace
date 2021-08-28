const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VaultCreator", () => {
    let VaultCreator, vaultCreator;

    beforeEach(async () => {
        VaultCreator = await ethers.getContractFactory("VaultCreator");
        vaultCreator = await VaultCreator.deploy();
    });

    it("emit Create New Vault event when createVault function is called", async () => {
        expect(vaultCreator.createVault())
            .to
            .emit(vaultCreator, "CreateNewVault")
            .withArgs("New Vault Created");
    });

});