// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    /*
    @param minDelay: The minimum time for a proposal to be executed
    @param proposers: The addresses that can propose a new proposal
    @param executors: The addresses that can execute a proposal
        */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin) 
    TimelockController(minDelay, proposers, executors, admin) {}
}
