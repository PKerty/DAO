//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {

    constructor(address owner) Ownable(owner){}

    uint256 private s_value;

    event ValueChanged(uint256 value);

    function store(uint256 value) public onlyOwner {
        s_value = value;
        emit ValueChanged(value);
    }

    function retrieve() public view returns (uint256) {
        return s_value;
    }
}
