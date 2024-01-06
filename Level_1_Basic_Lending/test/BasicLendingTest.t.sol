// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BasicLending} from "../src/BasicLending.sol";

contract BasicLendingTest is Test {
    BasicLending basicLending;

    function setUp() external {
        basicLending = new BasicLending();
        // counter.setNumber(0);
    }

    function testMinDepIs10ETH() public {
      console2.log(basicLending.minDep());
      assertEq(basicLending.minDep(), 10e18);
    }

    // test that after a deposit, the balance of the depositor increases and the hasDeposited mapping returns true
    function testDeposit() public {
      uint256 amount_ = 10e18;
      basicLending.deposit{value: amount_}(amount_);
      assertEq(basicLending.balances(address(this)), amount_);
      assertTrue(basicLending.hasDeposited(address(this)));
    }

    // test that after a deposit, we withdraw the same amount and check that the balance of the depositor is zero
    function testWithdraw() public {
      uint256 amount_ = 100e18;
      basicLending.deposit{value: amount_}(amount_);
      basicLending.withdraw(amount_);
      assertEq(basicLending.balances(address(this)), 0);
    }

    // // test that after borrowing, the hasBorrowed mapping returns true
    function testHasBorrowedMapping() public {
      uint256 amount_;
      uint256 tvl = 100e18;
      uint256 balanceCheck = (basicLending.balances(address(this)) * 80) / 100;
      require(amount_ > 0 && amount_ <= tvl/100 && amount_ <= balanceCheck, "Not allowed!!!");
      basicLending.deposit{value: 500e18}(500e18);
      basicLending.borrow(amount_);
      assertTrue(basicLending.hasBorrowed(address(this)));
    }

    // function testHasBorrowedMapping() public {
    //    uint256 amount_ = 10e18;
    //    basicLending.deposit{value: 500e18}(500e18);
    //    uint256 tvl = 100e18;
    //    uint256 balanceCheck = (basicLending.balances(address(this)) * 80) / 100;
    //    require(amount_ > 0 && amount_ <= tvl/100 && amount_ <= balanceCheck, "Not allowed!!!");
    //    basicLending.borrow(amount_);
    //    assertTrue(basicLending.hasBorrowed(address(this)));
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
