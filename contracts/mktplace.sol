//SPDX-License-Identifier: GPL-3.0
 pragma solidity ^0.8.0;

contract VaultCreator { 

address public MktplaceAdmin;  // public state variable automatically has getter function 
Vault[] public deployedVaults; // public array automatically has getter function 
   
   constructor(){ 
     MktplaceAdmin = msg.sender; //  Contract Administrator, not new Vault owner   
   }
  
  /*1. User Makes a Vault*/
  function createVault() public {
     Vault new_vault_address = new Vault(msg.sender); // pass caller to Vault constructor as eoa; makes them owner of a their Vault 
     deployedVaults.push(new_vault_address); // track these Vaults
   } 
   // Carlos: made this, but not sure if we'll need it, was trying to test something 
   modifier OnlyMktplaceAdmin() { 
      require(msg.sender == MktplaceAdmin, "Only Mktplace Administrators can use this function");
      _; 
   } 
}

contract Vault { 

   address payable public owner; // publicly visible owner of the Vault who gets paid by winner
   uint highestLiveBid; //highest bid amongst all numLiveBids
   address public highestBidder; //highest bidder among all bidders
   uint public debt; // for when user takes loans
   struct Bid { 
       address bidderAddress;
       uint startBlock;
       uint endBlock;
       uint amount;
   }
   mapping (address => Bid) BidderBids;

   // Vault has 5 Vault States
   enum VState {Open, Published, LoanOutstanding, LiquidationEligible, Closed}
   VState public vaultStatus;

  // 1. User Makes a Vault: with this constructor 
   constructor(address eoa){ 
      owner = payable(eoa); 
      vaultStatus = VState.Open; 
      numLiveBids = 0;
      debt = 1; // Constructed with 1 on purpose to simulate interest. 
                  // use debt = debt + loan; make sure to payback more than loaned
   }

 modifier OnlyOwner {
    require(msg.sender == owner, "Only the vault owner can call this function.");
    _;
   }

// 2. Add Assets @ Maks 
    // Backup plan: write this so that vault owner can add ETH
function AddAsset() external payable OnlyOwner { 


}

// 3. Owner Withdraw Assets    @ Maks 
    // Should work if Vault is OPEN or CLOSED 

function WithdrawAsset() external OnlyOwner { 


}

// 4.  Publish Vault  @ Josh 
    // Vault must be Open
    // Optional: Vault must have stuff in it
function PublishVault() external OnlyOwner { 


}    

// 5. Close a Vault  @ Josh  
    // Vault must be Open OR Published

function CloseVault() external onlyOwner { 


}

// 6. Bidders Bid  @ Marc 
    // need to read block metadata to create the Bid Struct and add it to the mapping 
function placeBid() external { 

Bid memory newBid = Bid({
     bidderAddress : msg.sender,
       startBlock : block.number,
        endBlock : block.number + 10,
        amount : msg.value
     }
     );
     
     BidderBid[msg.sender] = newBid;

     // IF msg.value > highestLiveBid update highestLiveBid & highestLiveBidder - @ Marc 
}

// 7. Bidder Request Withdrawal  @ Carlos 

// CheckLiquidation Function 

// Withdraw Bid 

function withdrawBid() external { 
require(block.number >= BidderBid[msg.sender].EndBlock, "Your bid has not expired");

if(BidderLiveCheck[msg.sender] == 1){
numLiveBids = numLiveBids - 1
}

If( vaultStatus == VState.LoanOutstanding){
checkLiquidationEligible()
}
}
if(vaultStatus = VState.LiquidationEligible){
if (msg.sender == HighestLiveBidder){
BidderLiveCheck(msg.sender) = 0;
BidderBid[msg.sender].amount = 0;
HighestLiveBid = 0
ChangeVaultOwnerToHLB()
vaultStatus = VState.Published
} else Transfer(BidderBid[msg.sender].Amount, msg.sender)
}

}

}

// 8. Owner Takes a loan @ Vivien 
 // Require vault be status Published
 // only allow up to highest live bid 
 // update debt
 // change to loan outstanding
// then transfer at the very end 

function getLoan() external onlyOwner { 


}

// 9. Owner Pays loan - @ Marc 
 // Require Vault be status LoanOutstanding 
 // reduce debt as needed 
 // Change to Published IF ALL debt is paid 
function payLoan() external onlyOwner { 



}