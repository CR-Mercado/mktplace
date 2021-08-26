//SPDX-License-Identifier: GPL-3.0
 pragma solidity ^0.8.0;

/*Contract to Create Vaults: */

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
}

contract Vault { 

address payable public owner; // publicly visible owner of the Vault who gets paid by winner
enum State {Open, Published, LoanOutstanding, LiquidationEligible, Closed} 
State public vaultStatus;

constructor(address eoa){ 
owner = payable(eoa); 
vaultStatus = State.Open; /*2. Vault Status defaults to OPEN*/
}

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

/*11. Loan is Binary, they take 0 or they take max BID 
@ Vivien - User requests loan, check if bids exist, give them highest live bid, change vault to loan outstanding
*/

/*12. When loan taken, Vault is LOAN OUTSTANDING
@ Vivien - User requests loan, check if bids exist, give them highest live bid, change vault to loan outstanding
*/

/*13. User receives loan
@ Vivien - User requests loan, check if bids exist, give them highest live bid, change vault to loan outstanding
*/

/*14. User can pay back loan 
@ Maks - user can submit ETH to the contract 
*/

/*15. Check if User paid in full 
@ Carlos - function that only changes Loan Outstanding -> Published IF debt == 0 
*/

/*16. If paid in full Vault Status is PUBLISHED
@ Carlos - function that only changes Loan Outstanding -> Published IF debt == 0 
*/

/*17. Bidder can request withdraw of their money
@ Josh - this needs to check their bid, if its expired or not (can't withdraw early)
*/

/*18. Withdrawal request: Check if Bid expire time has passed 
@ Josh - this needs to check their bid, if its expired or not (can't withdraw early)
*/

/*19. Withdrawal request: check if Vault should be liquidated 
@ Josh/Carlos 
*/

/*20. If Loan Outstanding - Vault is LIQUIDATION ELIGIBLE
 @Josh/Carlos
 */

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
