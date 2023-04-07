// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract SecurityManager is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    
    constructor(address admin) {
        _grantRole(ADMIN_ROLE, admin);
    }
    
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return super.hasRole(role, account);
    }
    
    function renounceRole(bytes32 role, address account) public virtual override  {
        super.renounceRole(role, account);
    }
    
    function revokeRole(bytes32 role, address account) public virtual override  {
        super.revokeRole(role, account);
    }
}