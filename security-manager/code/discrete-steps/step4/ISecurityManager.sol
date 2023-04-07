// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// added this interface to hide the implementation of SecurityManager
interface ISecurityManager {
    function hasRole(bytes32 role, address account) external view returns (bool);
}