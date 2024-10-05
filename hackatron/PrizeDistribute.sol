// SPDX-License-Identifier: MIT
/*
    * This contract is used to distribute prize money to multiple payees.
    * The owner of the contract can add payees and specify the share of the prize money they are entitled to.
    * The owner can also specify the payer of the prize money.
    * The payer can then send the prize money to the contract, which will then distribute the prize money to the payees.
    * The contract can also be updated with a new token contract address for distribution.
    */
pragma solidity ^0.8.20;

interface ITRC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract PrizeDistribute {
    struct Payee {
        //Team Member
        address payable account;
    }
    struct Payer {
        // org thats paying the prize 
        address account;
    }

    address public owner;
    ITRC20 public usdtToken;
    Payee[] public payees;
    Payer public payer;

    event PayeeAdded(address account);
    event PayeeRemoved(address account);
    event PayerAdded(address account);
    event RoyaltiesDistributed(uint256 amount);
    event DistributionFailed(address account, uint256 amount);
    event TokenContractUpdated(address newTokenContract);
    event PaymentRecieved();
    event PaymentDistributed(address account, uint256 amount);
    
    // test events
    event distributeCalled();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner may call function");
        _;
    }

    constructor(address _usdtToken) {
        owner = msg.sender;
        usdtToken = ITRC20(_usdtToken);
    }

    /**
     * @notice Distributes the token to the payees
     */
    function distribute() internal {
        emit distributeCalled();
        // require the pool sent the owner money (aka they won)
        
                   
        // payment = getCurrentWalletAmnt / payees.length
        uint256 payment = address(this).balance / payees.length;
        
        // loop thu payees
        for(uint256 i = 0; i < payees.length; i++){
            // get payee
            Payee memory payee = payees[i];

            // pay payee
            payable(payee.account).transfer(payment);
            emit PaymentDistributed(payee.account, payment);
        }
    }

    /**
     * @notice Distributes the token to the payees
     */
    function distributeManual() public onlyOwner {
        emit distributeCalled();
        // require the pool sent the owner money (aka they won)
        
                   
        // payment = getCurrentWalletAmnt / payees.length
        uint256 payment = address(this).balance / payees.length;
        
        // loop thu payees
        for(uint256 i = 0; i < payees.length; i++){
            // get payee
            Payee memory payee = payees[i];

            // pay payee
            payable(payee.account).transfer(payment);
            emit PaymentDistributed(payee.account, payment);
        }
    }


    /**
     * @notice Accepts payment from the payer
     */
    function acceptPayment() external payable {
        // Check if the sender is the authorized address
        // require(msg.sender == payer.account, "You are not authorized to send payment");

        // Ensure that a valid amount is being sent
        require(msg.value > 0, "Payment value must be greater than 0");
        
        emit PaymentRecieved();
        
        distributeManual();
    }

    /**
     * @notice Adds a new payer
     * @param account Address of new payer
     */
    function addPayer(address account) external onlyOwner {
        require(account != address(0), "Account is the zero address"); //This helps to protect users from adding the 0 address (burn address)
        payer = Payer(account);
        emit PayerAdded(account);
    }

    /**
     * @notice Adds a new payee with a specified share
     * @param account Address of new payee
     */
    function addPayee(address payable account) external onlyOwner {
        require(account != address(0), "Account is the zero address"); //This helps to protect users from adding the 0 address (burn address)
        payees.push(Payee(account));
        emit PayeeAdded(account);
    }

    /**
     * @notice Removes an existing payee
     * @param account Address of payee to remove
     */
    // function removePayee(address account) external onlyOwner {
    //     require(account != address(0), "Account is the zero address");

    //     for (uint256 i = 0; i < payees.length; i++) {
    //         if (payees[i].account == account) {
    //             totalShares = totalShares - payees[i].share; //Deduct the to be removed account shares from the total shares

    //             // Swap with the last element and pop
    //             payees[i] = payees[payees.length - 1];
    //             payees.pop();

    //             emit PayeeRemoved(account);
    //             break;
    //         }
    //     }
    // }


    /**
     * @notice Returns the current balance of the contract
     */
    function current_balance() external onlyOwner returns (uint256){
        return address(this).balance;
    }

    /**
     * @notice Updates the token contract address for distribution
     * @param newTokenContract Address of new token for this contract to distribute
     */
    function updateTokenContract(address newTokenContract) external onlyOwner {
        require(
            newTokenContract != address(0),
            "New token contract is the zero address"
        );
        usdtToken = ITRC20(newTokenContract);
        emit TokenContractUpdated(newTokenContract);
    }
}