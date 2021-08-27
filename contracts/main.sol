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
   uint public numLiveBids; //increment this when bids come in and when withdraws happen 
   uint highestBid; //highest bid amongst all numLiveBids
   address public highestBidder; //highest bidder among all bidders
   uint public debt; // for when user takes loans

   // Vault has 5 Vault States
   enum VState {Open, Published, LoanOutstanding, LiquidationEligible, Closed}
   VState public vaultStatus;
  
   /*2. Vault Status defaults to OPEN*/
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

   /*3. User Adds Asset(s) - for POC: Add a single NFT
   @ Maks - ERC721 - addAsset() , transfer. 
   */

   /*4. User is finished adding, publishes vault, Vault Status is PUBLISH
   @ Josh - on Vault Status changes 
   */

   /*5. User can close a vault
   @ Josh - on Vault Status changes 
   */
   /*6. Check Vault is NOT Loan Outstanding NOR Liquidation Eligible 
   @ Josh - on Vault Status changes 
   */

   /*7. Close Vault if checks passed
   @ Josh - on Vault Status changes 
   */

   /*8. Bidder can make bid - BID IS LOCKED (5 minutes for POC) 
   @ Marc - Contract able to accept deposits (ETH), think about how they can be locked, should bid have a bid status? 
   should bid be a struct? 
   */

   /*9. Vault accepts Bids in ETH, noting who submitted what, what they submitted and HIGHEST LIVE BID
   @ Marc - all the metadata about a bid: who, how much, is it the highest?
   */

   /*10. User can request a Loan
   @ Vivien - User requests loan, check if bids exist, give them highest live bid, change vault to loan outstanding
   */
  
  // normally would use uint _amount but we will assume they take the max for the proof of concept
function requestLoan() external OnlyOwner { 
require(vaultStatus == VState.Published, "Only published vaults can take loans");


}



  event LoanApproval(address indexed _borrower, address indexed _lender, uint indexed _value);
  

  function getLoan(address _borrower, address _lender, uint _value) internal onlyOwner {
    //require(msg.sender == owner); //check that person who wants to take loan == owner of vault

    if(_value == highestBid) {
     emit LoanApproval(msg.sender, _lender, highestBid);
    }
  }

   /*11. Loan is Binary, they take 0 or they take max BID 
   @ Vivien - User requests loan, check if bids exist, give them highest live bid, change vault to loan outstanding
   */

   /*12. When loan taken, Vault is LOAN OUTSTANDING
   @ Vivien - User requests loan, check if bids exist, give them highest live bid, change vault to loan outstanding
   */
  //event Transfer(address indexed _lender, address indexed _borrower, uint indexed _value);  
  function transferLoan(address payable _account, uint _amount) payable public onlyOwner {
    require(vaultStatus == VState.Published, "Only published vaults with bids can take loans.");
   
    recipient = payable(_account);
    debt += _amount;
    // debt += msg.value; - It won't be msg.value, this is a request for money, not a deposit.

    vaultStatus = VState.LoanOutstanding;
    
    //emit Transfer(_lender, _borrower, highestBid);
    
    address(recipient).transfer(msg.value);

  }

   /*13. User receives loan
   @ Vivien - User requests loan, check if bids exist, give them highest live bid, change vault to loan outstanding
   */

   /*14. User can pay back loan 
   @ Maks - user can submit ETH to the contract 
   */

   /*15. Check if User paid in full*/
   // function is internal, only called by other functions in this contract
   // assumes debt is stored & calculated at loan withdrawal & repayment ** <- discuss with Vivien (13)
   // if there's no debt, then this closes the loan, makes the State Published, 
   //    and returns FALSE (not Liquidation Eligible)
   // if there is debt - and for this POC all Bids are expired- then it can be liquidated  

   function CheckLiquidationEligible(uint _debt) public returns(bool) { 
      require(vaultStatus == VState.LoanOutstanding, "No loans outstanding on this vault.");

      /*16. If paid in full Vault Status is PUBLISHED */
      if( _debt == 0 ){ 
         vaultStatus = VState.Published;
         return(false);
      } else { 
         vaultStatus = VState.LiquidationEligible;
         return(true);
      }
   }

   // Test 
   // Success: 
      // Uses the two internal Force functions and passes the debt state variable, which is 1 when constructed.  
   function TestLiquidationEligible() external returns(bool) { 
      forceLoanOutStanding();
      CheckLiquidationEligible(debt);
      if(vaultStatus == VState.LiquidationEligible){ 
         return(true);
      } else 
         return(false);
   }

   function forceLoanOutStanding() internal { 
      vaultStatus = VState.LoanOutstanding;
   }

   /*17. Bidder can request withdraw of their money
   @ Josh - this needs to check their bid, if its expired or not (can't withdraw early)
   */
   function bidWithdraw() public {
      /*18. Withdrawal request: Check if Bid expire time has passed 
      @ Josh - this needs to check their bid, if its expired or not (can't withdraw early)
      */

      /*19. Withdrawal request: check if Vault should be liquidated 
      20. If Loan Outstanding - Vault is LIQUIDATION ELIGIBLE */
      CheckLiquidationEligible(debt);
   }


   /*21. If Bidder is HIGHEST LIVE BID & LIQUIDATION ELIGIBLE do NOT withdraw, instead transfer Vault
   @ Josh - this needs to check their bid, if its expired or not (can't withdraw early)
   */

   /*22. If Bidder is NOT Highest Live Bid, continue withdrawal (if time expired) - Liquidate if applicable 
   @ Josh - this needs to check their bid, if its expired or not (can't withdraw early)
   */ 

   /*23. transfer vault // change owner of Vault 
   @ Marc - check relevant conditions (liquidation eligible)
   */

   /*24. If liquidated, VAULT is CLOSED 
   @ Marc - change status if Josh's stuff goes through 
   */

} // Here is the end of Vault contract 
