- implement a SecurityManager contract
- modify the Contract to use a reference to SecurityManager instead of inheriting AccessControl

Here, a SecurityManager contract is created (which controls access via OpenZeppelin's AccessControl), and Contract is changed so that it refers to an instance of the SecurityManager. See that SecurityManage provides the necessary access to the underlying security protocols, by allowing callers to query, revoke, renounce, and grant roles. 