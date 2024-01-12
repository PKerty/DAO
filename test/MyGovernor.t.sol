// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "@src/Governor.sol";
import {Box} from "@src/Box.sol";
import {TimeLock} from "@src/TimeLock.sol";
import {GovToken} from "@src/GovernanceToken.sol";



contract GovernorTest is Test {

    MyGovernor governor;
    Box box;
    TimeLock timeLock;
    GovToken govToken;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600;
    uint256 public constant VOTING_DELAY = 1;
    uint256 public constant VOTING_PERIOD = 50400;

    address[] public proposers;
    address[] public executors;

    uint256[] values;
    bytes[] callDatas;
    address[] targets;

    function setUp() public {
        govToken = new GovToken(); 
        govToken.mint(address(this), INITIAL_SUPPLY);
        govToken.delegate(address(this));
        timeLock = new TimeLock(MIN_DELAY, proposers, executors, address(this));

        governor = new MyGovernor(govToken,timeLock);
        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();
        timeLock.grantRole(proposerRole, address(governor));
        timeLock.grantRole(executorRole, address(0));
        timeLock.revokeRole(adminRole, address(this));
        box = new Box(address(timeLock));

    }

    function testCantUpdateWithoutGovernanceToken() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;

        string memory description = "store 888 in box";
        callDatas.push(abi.encodeWithSignature("store(uint256)", valueToStore));
        values.push(0);
        targets.push(address(box));
        uint256 proposalId = governor.propose(targets, values, callDatas, description);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        string memory reason = "because yes";
        uint8 voteWay = 1;
        governor.castVoteWithReason(proposalId, voteWay, reason);

        
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        console.log("Proposal State:", uint256(governor.state(proposalId)));

        governor.queue(targets, values, callDatas, descriptionHash);


        vm.warp(block.timestamp + MIN_DELAY +  1);
        vm.roll(block.number + MIN_DELAY +  1);


        governor.execute(targets, values, callDatas, descriptionHash);

        console.log("value: ", box.retrieve());

        assert(box.retrieve() == valueToStore);

    }

/*

    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
*/
}
