//SPDX-License-Identifier: GPL-3.0
 pragma solidity ^0.8.0;

/*Contract to Create Vaults: */

contract VaultCreator { 


}

/*1. User Makes a Vault*/

contract Vault { 


}

/*2. Vault Status defaults to OPEN*/

/*3. User Adds Asset(s) - for POC: Add a single NFT*/

/*4. User is finished adding, publishes vault, Vault Status is PUBLISH*/

/*5. User can close a vault*/

/*6. Check Vault is NOT Loan Outstanding NOR Liquidation Eligible */

/*7. Close Vault if checks passed*/

/*8. Bidder can make bid - BID IS LOCKED (5 minutes for POC) */

/*9. Vault accepts Bids in ETH, noting who submitted what, what they submitted and HIGHEST LIVE BID*/

/*10. User can request a Loan*/

/*11. Loan is Binary, they take 0 or they take max BID */

/*12. When loan taken, Vault is LOAN OUTSTANDING*/

/*13. User receives loan*/

/*14. User can pay back loan */

/*15. Check if User paid in full */

/*16. If paid in full Vault Status is PUBLISHED*/

/*17. Bidder can request withdraw of their money*/

/*18. Withdrawal request: Check if Bid expire time has passed */

/*19. Withdrawal request: check if Vault should be liquidated */

/*20. If Loan Outstanding - Vault is LIQUIDATION ELIGIBLE*/

/*21. If Bidder is HIGHEST LIVE BID & LIQUIDATION ELIGIBLE do NOT withdraw, instead transfer Vault */

/*22. If Bidder is NOT Highest Live Bid, continue withdrawal (if time expired) - Liquidate if applicable */ 

/* 23. transfer vault // change owner of Vault */

/*24. If liquidated, VAULT is CLOSED */

