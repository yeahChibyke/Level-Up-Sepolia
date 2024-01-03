// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0 < 0.9.0;

contract BasicLending {
    // minimum amount of ETH that can be deposited
    uint256 public minDep = 1e18;

    // minimum amount of ETH that can be withdrawn
    uint256 public minWit = 1e18;

    // list of depositors
    address[] public depositors;

    // list of withdrawers
    address[] public withdrawers;

    // mapping to keep track of users ETH balance
    mapping (address => uint256) public balances;

    // mapping to keep track of amount each user borrows
    mapping (address => uint256) public borrowedAmount;

    // mapping to keep track of whether an account has made a deposit
    mapping(address => bool) public hasDeposited;

    // event to track whenever a deposit is made
    event DepositSuccessful(address user, uint256 amount);

    // event to track whenever a withdrawal is made
    event WithdrawalSuccessful(address user, uint256 amount);

    // function for users to deposit funds
    function deposit(uint256 amount_) payable external {
        require(amount_ >= minDep, "Amount lower than minimum deposit!");

        balances[msg.sender] += amount_;
        depositors.push(msg.sender);
        hasDeposited[msg.sender] = true;
        emit DepositSuccessful(msg.sender, amount_);
    }

    // function for users to withdraw funds
    function withdraw(uint256 amount_) payable external yesDeposited {
        require(minWit <= address(this).balance, "Withdrawals not available currently. Check back later!");
        require(amount_ >= minWit, "Amount lower than minimum withdrawal!");
        require(balances[msg.sender] >= amount_, "Not enough balance to withdraw");

        balances[msg.sender] -= amount_;
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Transfer failed.");

        emit WithdrawalSuccessful(msg.sender, amount_);
    }

    modifier yesDeposited() {
        require(hasDeposited[msg.sender], "You have not made a deposit yet!");
        _;
    }
}
