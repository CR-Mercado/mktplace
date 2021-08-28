//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


  contract Vault is IERC721Receiver {
    address payable public owner; // publicly visible owner of the Vault who gets paid by winner
    uint256 highestLiveBid;
    address public highestLiveBidder; //highest bidder among all bidders
    uint256 public debt; // for when user takes loans
    ERC721 public nftAddress;
    uint256 public tokenId;


    struct Bid {
        address bidderAddress;
        uint256 startBlock;
        uint256 endBlock;
        uint256 amount;
    }
    mapping(address => Bid) BidderBids;

    // Vault has 5 Vault States
    enum VState {
        Open,
        Published,
        LoanOutstanding,
        LiquidationEligible,
        Closed
    }
    VState public vaultStatus;

    // 1. User Makes a Vault: with this constructor
    constructor(address eoa) {
        owner = payable(eoa);
        vaultStatus = VState.Open;
        debt = 1; // Constructed with 1 on purpose to simulate interest.
        // use debt = debt + loan; make sure to payback more than loaned
    }

    modifier OnlyOwner() {
        require(
            msg.sender == owner,
            "Only the vault owner can call this function."
        );
        _;
    }

    // 2. Add Assets @ Maks
    // Backup plan: write this so that vault owner can add ETH

    function AddAsset(address _nftAddress, uint256 _id) external OnlyOwner {
        ERC721 nftAddress = ERC721(_nftAddress); 
        nftAddress.safeTransferFrom(msg.sender, address(this), _id);
    }

    function onERC721Received (
      address _operator,
        address _from,
      uint256 _tokenId,
      bytes calldata _data
    ) external override returns (bytes4) {
      nftAddress = ERC721(msg.sender);
      tokenId = _tokenId;
      return 0x150b7a02;
    }


    // 3. Owner Withdraw Assets    @ Maks
    // Should work if Vault is OPEN or CLOSED

    function WithdrawAsset(address _nftAddress, uint256 _id) external OnlyOwner {
      ERC721 THEnftAddress = ERC721(_nftAddress);
      THEnftAddress.safeTransferFrom(address(this), msg.sender, _id);
    }

    // 4.  Publish Vault  @ Josh
    // Vault must be Open
    // Optional: Vault must have stuff in it
    function PublishVault() external OnlyOwner {
        require(
            vaultStatus == VState.Open,
            "Vault must be open to publish it."
        );
        vaultStatus = VState.Published;
    }

    // 5. Close a Vault  @ Josh
    // Vault must be Open OR Published
    function CloseVault() external OnlyOwner {
        require(
            vaultStatus == VState.Open || vaultStatus == VState.Published,
            "Vault must be open or published to close it."
        );
        vaultStatus = VState.Closed;
    }

    // 6. Bidders Bid  @ Marc
    // need to read block metadata to create the Bid Struct and add it to the mapping
    function placeBid() external payable {
        Bid memory newBid = Bid({
            bidderAddress: msg.sender,
            startBlock: block.number,
            endBlock: block.number + 10,
            amount: msg.value
        });

        BidderBids[msg.sender] = newBid;

        // IF msg.value > highestLiveBid update highestLiveBid & highestLiveBidder - @ Marc
    }

    // 7. Bidder Request Withdrawal  @ Carlos

    // checkLiquidation Function
    function checkLiquidationEligible(uint256 _debt) internal returns (bool) {
        require(
            vaultStatus == VState.LoanOutstanding,
            "No loans outstanding on this vault."
        );
        /*If there is debt, make vault LiquidationEligible*/
        if (_debt == 0) {
            vaultStatus = VState.Published;
            return (false);
        } else {
            vaultStatus = VState.LiquidationEligible;
            return (true);
        }
    }

    // Test
    // Uses the internal Force functions and passes the debt state variable, which is 1 when constructed.
    function forceLoanOutStanding() internal {
        vaultStatus = VState.LoanOutstanding;
    }

    function TestLiquidationEligible() external returns (bool) {
        forceLoanOutStanding();
        checkLiquidationEligible(debt);
        if (vaultStatus == VState.LiquidationEligible) {
            return (true);
        } else return (false);
    }

    // change vault owner

    function changeVaultOwnerToHLB() internal {
        owner = payable(highestLiveBidder);
    }

    // Withdraw Bid
    function withdrawBid() public {
        require(
            block.number >= BidderBids[msg.sender].endBlock,
            "Your bid has not expired."
        );
        require(
            BidderBids[msg.sender].amount > 0,
            "You do not have a bid to withdraw."
        );

        // If there's a loan out, check for liquidation eligibility
        if (vaultStatus == VState.LoanOutstanding) {
            checkLiquidationEligible(debt);
        }

        if (vaultStatus == VState.LiquidationEligible) {
            // If liquidated by highestLiveBidder, keep the money and give them the vault
            if (msg.sender == highestLiveBidder) {
                BidderBids[msg.sender].amount = 0;
                highestLiveBid = 0;
                debt = 0;
                changeVaultOwnerToHLB();
                vaultStatus = VState.Published;

                // if liquidated by anyone else, they can withdraw just fine
            } else {
                uint256 value = BidderBids[msg.sender].amount;
                address payable recipient = payable(msg.sender);
                BidderBids[msg.sender].amount = 0;
                recipient.transfer(value);
            }
            // If vault does not have a loan / is not liquidation eligible, withdraw their money
            // NOTE: this should check for 2nd highest loan and update highestLiveBidder & highestLiveBid but
            // skipping that for proof of concept.
        } else {
            uint256 value = BidderBids[msg.sender].amount;
            address payable recipient = payable(msg.sender);
            BidderBids[msg.sender].amount = 0;
            recipient.transfer(value);
        }
    }

    // Test withdraw

    function PlaceFakeBids() internal {
        // "Bobby" Bid
        address bobby_address = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        Bid memory Bobby = Bid({
            bidderAddress: bobby_address,
            startBlock: block.number - 5,
            endBlock: block.number - 1,
            amount: 1000
        });

        if (highestLiveBid <= 1000) {
            highestLiveBid = Bobby.amount;
            highestLiveBidder = bobby_address;
        }

        BidderBids[bobby_address] = Bobby;

        // "Suzie" Bid
        address suzie_address = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        Bid memory Suzie = Bid({
            bidderAddress: suzie_address,
            startBlock: block.number,
            endBlock: block.number + 10,
            amount: 500
        });

        if (highestLiveBid <= 500) {
            highestLiveBid = Suzie.amount;
            highestLiveBidder = suzie_address;
        }

        BidderBids[suzie_address] = Suzie;
    }

    modifier onlyBobby() { 
    require(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "Only Bobby's wallet can call this function");
    _;
    }

    function testWithdrawal() payable external onlyBobby returns(bool) {
        // load bobby and suzie's funding ahead of time 
        // add their bids 
        // change vault to loanOutstanding 
        // use bobby's address to withdraw
        // his acccount balance should NOT change, instead he becomes owner 
        require(msg.value == 1500, "You need to fund the fake bids to keep the contract balance intact.");

        PlaceFakeBids(); // bobby becomes HLB
        if(debt > 0){
        vaultStatus = VState.LoanOutstanding;
        }
        withdrawBid();
        if(owner == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            return(true);
        } else {
            return(false);
        }
    }

    // 8. Owner Takes a loan @ Vivien
    // Require vault be status Published
    // only allow up to highest live bid
    // update debt
    // change to loan outstanding
    // then transfer at the very end

    event LoanTransferred(
        address indexed _borrower,
        address indexed _lender,
        uint256 indexed _value
    );

    function getLoan() external OnlyOwner {
        
        require(
            vaultStatus == VState.Published,
            "Only published vaults can take loans."
        );
        
        require(
            highestLiveBid != 0,
            "There are no bids for your vault."
        );
        
        //update statuses
        debt += highestLiveBid;
        vaultStatus = VState.LoanOutstanding;

        //transfer loan
        address payable recipient = payable(msg.sender);
        recipient.transfer(highestLiveBid);
        
        emit LoanTransferred(msg.sender, highestLiveBidder, highestLiveBid);
    }

    // 9. Owner Pays loan - @ Marc
    // Require Vault be status LoanOutstanding
    // reduce debt as needed
    // Change to Published IF ALL debt is paid (change to Closed)
    function payLoan() external OnlyOwner {}
} // end contract
