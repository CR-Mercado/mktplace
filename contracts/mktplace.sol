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
   uint highestLiveBid; 
   address public highestLiveBidder; //highest bidder among all bidders
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

function CloseVault() external OnlyOwner { 


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
function CheckLiquidationEligible(uint _debt) internal returns(bool) { 
      require(vaultStatus == VState.LoanOutstanding, "No loans outstanding on this vault.");

        /*If there is debt, make vault LiquidationEligible*/
      if( _debt == 0 ){ 
         vaultStatus = VState.Published;
         return(false);
      } else { 
         vaultStatus = VState.LiquidationEligible;
         return(true);
      }
   }

        // Test  
     // Uses the internal Force functions and passes the debt state variable, which is 1 when constructed.  
    function forceLoanOutStanding() internal { 
      vaultStatus = VState.LoanOutstanding;
   }

   function TestLiquidationEligible() external returns(bool) { 
      forceLoanOutStanding();
      CheckLiquidationEligible(debt);
      if(vaultStatus == VState.LiquidationEligible){ 
         return(true);
      } else 
         return(false);
   }

        // change vault owner 

    function changeVaultOwnerToHLB() internal { 
        owner = highestLiveBidder;
    }
        // Withdraw Bid
    function withdrawBid() external { 
        require(block.number >= BidderBid[msg.sender].EndBlock, "Your bid has not expired.");
        require(BidderBid[msg.sender].amount > 0, "You do not have a bid to withdraw.");
        
        // If there's a loan out, check for liquidation eligibility
        if(vaultStatus == VState.LoanOutstanding){
            checkLiquidationEligible();
            } 

        if (vaultStatus == VState.LiquidationEligible){
            // If liquidated by highestLiveBidder, keep the money and give them the vault
            if (msg.sender == HighestLiveBidder){
                BidderBid[msg.sender].amount = 0;
                HighestLiveBid = 0;
                debt = 0;
                changeVaultOwnerToHLB();
                vaultStatus = VState.Published;

            // if liquidated by anyone else, they can withdraw just fine
                } else { 
                    value = BidderBid[msg.sender].amount;
                    recipient = payable(msg.sender);
                    BidderBid[msg.sender].amount = 0; 
                    recipient.transfer(value);
                }
        // If vault does not have a loan / is not liquidation eligible, withdraw their money
        // NOTE: this should check for 2nd highest loan and update highestLiveBidder & highestLiveBid but
        // skipping that for proof of concept.
        } else { 
            value = BidderBid[msg.sender].amount;
                    recipient = payable(msg.sender);
                    BidderBid[msg.sender].amount = 0; 
                    recipient.transfer(value);
        }
    } 

// Test withdraw 

    function PlaceFakeBids() internal { 
        // "Bobby" Bid 
        address bobby_address =  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
     
        Bid memory Bobby = Bid({
            bidderAddress : bobby_address,
            startBlock : block.number,
            endBlock : block.number + 10,
            amount : 1000
        });

        if(highestLiveBid <= 1000){ 
            highestLiveBid = Bobby.amount;
            highestLiveBidder = bobby_address;
        } 

        BidderBid[bobby_address] = Bobby;
        
        // "Suzie" Bid 
        address suzie_address =  0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
     
        Bid memory Suzie = Bid({
            bidderAddress : suzie_address,
            startBlock : block.number,
            endBlock : block.number + 10,
            amount : 500
        });

        if(highestLiveBid <= 500){ 
            highestLiveBid = Suzie.amount;
            highestLiveBidder = suzie_address;
        } 

        BidderBid[suzie_address] = Suzie;
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


} // end contract