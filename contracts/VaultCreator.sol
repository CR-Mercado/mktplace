//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./mktplace.sol";

contract VaultCreator {
    address public MktplaceAdmin; // public state variable automatically has getter function
    Vault[] public deployedVaults; // public array automatically has getter function

    constructor() {
        MktplaceAdmin = msg.sender; //  Contract Administrator, not new Vault owner
    }

    event CreateNewVault(string message);

    /*1. User Makes a Vault*/
    function createVault() public {
        Vault new_vault_address = new Vault(msg.sender); // pass caller to Vault constructor as eoa; makes them owner of a their Vault
        deployedVaults.push(new_vault_address); // track these Vaults
        emit CreateNewVault("New Vault Created");
    }

    // Carlos: made this, but not sure if we'll need it, was trying to test something
    modifier OnlyMktplaceAdmin() {
        require(
            msg.sender == MktplaceAdmin,
            "Only Mktplace Administrators can use this function"
        );
        _;
    }
}