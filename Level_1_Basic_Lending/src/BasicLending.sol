// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BasicLending {
    // uint256 varaibles
        // amount of funds available in the smart contract
        uint256 public tvl = address(this).balance;

        // minimum amount of ETH that can be deposited
        uint256 public minDep = 10e18;

    // address variables
        // list of depositors
        address[] public depositors;

        // list of withdrawers
        address[] public withdrawers;

        // list of borrowers
        address[] public borrowers;

    // mappings
        // mapping to keep track of users ETH balance
        mapping (address => uint256) public balances;

        // mapping to keep track of amount each user borrows
        mapping (address => uint256) public borrowed;

        // mapping to keep track of whether an account has made a deposit
        mapping (address => bool) public hasDeposited;

        // mapping to keep track of whether an account has borrowed
        mapping (address => bool) public hasBorrowed;

        // mapping to keep track of whether a borrower has repayed
        mapping (address borrowers => bool) public hasRepayed;

    // events
        // event to track whenever a deposit is made
        event DepositSuccessful(address user, uint256 amount);

        // event to track whenever a withdrawal is made
        event WithdrawalSuccessful(address user, uint256 amount);

        // event to track whenever a borrow is made
        event BorrowSuccessful(address user, uint256 amount);

        // event to track whenever a repay is made
        event RepaySuccessful(address user, uint256 amount);

    // functions proper
        // function for users to deposit funds
        function deposit(uint256 amount_) payable external {
            // check deposit
            require(amount_ >= minDep, "Amount lower than minimum deposit!");

            // update mapping
            balances[msg.sender] += amount_;
            // update list
            depositors.push(msg.sender);
            // update boolean
            hasDeposited[msg.sender] = true;
            //update tvl
            tvl += amount_;

            // emit event
            emit DepositSuccessful(msg.sender, amount_);
        }

        // function for users to withdraw funds
        function withdraw(uint256 amount_) external yesDeposited {
            // check withdrawal
            require(amount_ > 0, "Specify a valid amount to be withdrawn!");
            require(amount_ <= balances[msg.sender], "Insufficient funds for withdrawal!");

            // update tvl
            tvl -= amount_;
            // update mapping
            balances[msg.sender] -= amount_;
            // update list
            withdrawers.push(msg.sender);

            // send funds to user
            (bool successful,) = payable(msg.sender).call{value: amount_}("");
            require(successful, "Withdrawal failed!");

            // emit event
            emit WithdrawalSuccessful(msg.sender, amount_);
        }

        // function for users to borrow funds
        function borrow(uint256 amount_) external yesDeposited {
            require(amount_ > 0, "Sepcify a valid amount to be borrowed!");
            require(amount_ <= tvl/100, "You cannot borrow more than 1% of TVL!"); // check to ensure no user can borrow more than 1% of TVL
            uint256 balanceCheck = (balances[msg.sender] * 80) / 100; 
            require(amount_ <= balanceCheck); // check to ensure no user can borrow more than 80% of their current balance

            // update the mapping
            borrowed[msg.sender] += amount_;
            // update boolean
            hasBorrowed[msg.sender] = true;
            // update list
            borrowers.push(msg.sender);
            // update tvl
            tvl -= amount_;

            // send funds to borrower
            (bool sent,) = payable(msg.sender).call{value: amount_}("");
            require(sent, "Borrow failed!");

            // emit event
            emit BorrowSuccessful(msg.sender, amount_);
        }

        // function for borrowers to repay debts
        function repay(uint256 amount_) payable external yesBorrowed {
            uint256 borrowedAmount = borrowed[msg.sender];
            uint256 interest = (borrowedAmount/10); // calculate 10% of the borrowed amount
            uint256 repayAmount = (borrowedAmount + interest); // add the interest to the borrowed amount
            // conduct checks
            require(amount_ == repayAmount, "You need to pay back the amount you borrowed plus the agreed interest!");

            // update mapping
            borrowed[msg.sender] -= amount_;
            // update boolean
            hasRepayed[msg.sender] = true;
            // update list to remove repayer from list of borrowers
                // find the index of the borrower in the borrowers array
                uint256 index = 0;
                for (index = 0; index < borrowers.length; index++) {
                    if(borrowers[index] == msg.sender) {
                        break;
                    }
                }
                // shift the elemnts of the found index down by 1
                for (uint256 i = index; i < borrowers.length - 1; i++) {
                    borrowers[i] = borrowers[i + 1];
                }
                // use pop to remove the last element
                borrowers.pop();
            // update tvl
            tvl += amount_;

            // emit event
            emit RepaySuccessful(msg.sender, amount_);
        }

    // modifiers
        modifier yesDeposited() {
            require(hasDeposited[msg.sender], "You have not made a deposit yet!");
            _;
        }

        modifier yesBorrowed() {
            require(hasBorrowed[msg.sender], "You didn't borrow any funds!");
            _;
        }
}
