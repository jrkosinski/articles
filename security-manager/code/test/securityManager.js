const { expect } = require("chai");
const { ethers } = require("hardhat");
const { 
    expectEvent, 
    expectRevert, 
    deploySecurityManager, 
    deployContract1, 
    deployContract2 
} = require("./testUtils");

describe("SecurityManager", function () {
    let securityManager, contract1, contract2;
    let admin, addr1, addr2; 	                //accounts
    let adminRole, managerRole;

    beforeEach(async function () {
        [admin, addr1, addr2, ...addrs] = await ethers.getSigners();

        securityManager = await deploySecurityManager(admin.address);
        contract1 = await deployContract1(securityManager.address);
        contract2 = await deployContract2(securityManager.address);

        adminRole = "0x0000000000000000000000000000000000000000000000000000000000000000";
        managerRole = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MANAGER_ROLE"));
    });

    it("admin can grant a non-admin role", async function () {
        expect(await securityManager.hasRole(managerRole, addr1.address)).to.be.false;
        
        await securityManager.connect(admin).grantRole(managerRole, addr1.address);
        expect(await securityManager.hasRole(managerRole, addr1.address)).to.be.true;
    });

    it("admin can grant an admin role", async function () {
        expect(await securityManager.hasRole(adminRole, addr1.address)).to.be.false;
        
        await securityManager.connect(admin).grantRole(adminRole, addr1.address);
        expect(await securityManager.hasRole(adminRole, addr1.address)).to.be.true;
    });

    it("admin can revoke a non-admin role", async function () {
        await securityManager.connect(admin).grantRole(managerRole, addr1.address);
        expect(await securityManager.hasRole(managerRole, addr1.address)).to.be.true;
        
        await securityManager.connect(admin).revokeRole(managerRole, addr1.address);
        expect(await securityManager.hasRole(managerRole, addr1.address)).to.be.false;
    });

    it("admin can revoke an admin role", async function () {
        await securityManager.connect(admin).grantRole(adminRole, addr1.address);
        expect(await securityManager.hasRole(adminRole, addr1.address)).to.be.true;
        
        await securityManager.connect(admin).revokeRole(adminRole, addr1.address);
        expect(await securityManager.hasRole(adminRole, addr1.address)).to.be.false;
    });

    it("non-admin cannot grant a role", async function () {
        await expectRevert(
            () => securityManager.connect(addr1).grantRole(adminRole, addr2.address), 
            "AccessControl:"
        );
    });

    it("manager cannot grant a role", async function () {
        //addr1 is manager 
        await securityManager.connect(admin).grantRole(managerRole, addr1.address);
        
        //can't grant roles 
        await expectRevert(
            () => securityManager.connect(addr1).grantRole(adminRole, addr2.address),
            "AccessControl:"
        );
    });

    it("non-admin cannot revoke a role", async function () {
        //addr2 has manager role 
        await securityManager.connect(admin).grantRole(managerRole, addr2.address);
        
        //addr1 can't revoke it 
        await expectRevert(
            () => securityManager.connect(addr1).revokeRole(managerRole, addr2.address),
            "AccessControl:"
        );
    });

    it("manager cannot revoke a role", async function () {
        //addr1 and addr2 are managers 
        await securityManager.connect(admin).grantRole(managerRole, addr1.address);
        await securityManager.connect(admin).grantRole(managerRole, addr2.address);

        //addr1 can't revoke addr2's role 
        await expectRevert(
            () => securityManager.connect(addr1).revokeRole(managerRole, addr2.address),
            "AccessControl:"
        );
    });

    it("anyone can renounce a role", async function () {
        //addr1 is manager
        await securityManager.connect(admin).grantRole(managerRole, addr1.address);
        expect(await securityManager.hasRole(managerRole, addr1.address)).to.be.true;
        
        //addr1 can renounce 
        await securityManager.connect(addr1).renounceRole(managerRole, addr1.address);
        expect(await securityManager.hasRole(managerRole, addr1.address)).to.be.false;
    });

    it.skip("admin can't renounce admin role", async function () {
        await expectRevert(
            () => securityManager.connect(admin).renounceRole(adminRole, admin.address),
            "AccessControl:"
        );
    });

    it.skip("admin can't revoke own admin role", async function () {
        await expectRevert(
            () => securityManager.connect(admin).revokeRole(adminRole, admin.address),
            "AccessControl:"
        );
    });

    it("can't pass zero address in constructor for SecurityManager", async function () {
        await expectRevert(
            () => deployContract1("0x0000000000000000000000000000000000000000"),
            "ZeroAddressArgument"
        );
    });

    it("can't pass zero address in setSecurityManager", async function () {
        await expectRevert(
            () => contract1.setSecurityManager("0x0000000000000000000000000000000000000000"),
            "ZeroAddressArgument"
        );
    });

    //can't pass invalid address in constructor for SecurityManager

    //can't pass invalid address in setSecurityManager

    //admin can call setSecurityManager

    //non-admin can't call setSecurityManager

    //granting roles gives access on both sub-contracts 
    
    //manager can call restricted method 
    
    //non-manager can't call restricted method 
});