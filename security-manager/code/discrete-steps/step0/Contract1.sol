// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Contract1 is AccessControl {
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    uint256 public restrictedValue2 = 0;
    
    constructor() {
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    function setRestrictedValue1(uint256 value) external onlyRole(bytes32(0)) {
        //implementation
        restrictedValue1 = value;
    }
    
    function setRestrictedValue2(uint256 value) external onlyRole(keccak256("MANAGER_ROLE")) {
        //implementation
        restrictedValue2 = value;
    }
}