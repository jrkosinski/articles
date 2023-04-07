- add code to SecurityManager.revokeRole to prevent stranding
- add code to SecurityManager.renounceRole to prevent stranding

When using role-based security, typically there is one role that's allowed to grant roles to accounts. If a contract was left without any users holding that one role (for example, if the one single admin accidentally revoked his own admin role), there could be no way for anyone to regain that role, short of redeploying the entire set of contracts. 

For this, I just (my own best practice here) like to add some protection against that. If the caller is ADMIN, in this case, the caller is not allowed to either renounce or revoke his _own_ admin role. Note that he can renounce the admin roles of other admins, just not his own. This makes it much less likely to encounter a death stranding situation. 