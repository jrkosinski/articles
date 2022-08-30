# The Case Against Upgradeable Smart Contracts 

## Introduction 

You are about to sign a lease to rent a house or aparment. The landlord: "This is just a standard rental agreement. We literally just googled one and copied it. _Except for the last clause which I added myself_, it's all just standard boilerplate". You take the time anyway, to read the contract carefully and thoroughly. Sure enough, it's all very standard and unsurprising. Pets are allowed, which is great because you can't part with your cat. Then you read the very last line: "All contents of this contract may be amended or changed completely by the property owner at any time, for any reason, without prior notification or consent of the renter." Well... this does not seem right. You read it again. You ask "So does this mean that you can, if you want, change the entire contract to read 'If any scratch on any furniture or paint is found, regardless of whether or not it was there originally, the renter owes the owner 10 times the market value of the property'?" The landlord replies: "Yes, well technically yeah I guess I could, yeah. But I wouldn't do that!" 

Let's talk about upgradeable smart contracts in EVM-compatible blockchains. 

## The Problem 

One of the most striking features of smart contract development is the inability to change anything once the contract is deployed. Consider a deployed web application: a bug discovered after deployment can be embarrassing, or harmful, but it can be fixed immediately before any further harm is done. In a deployed desktop or mobile app, it's a bit worse: users may have to intentionally download and install a new fixed version. But a smart contract is on the blockchain forever, immutable. This is a feature; users can trust the immutability of the contract. If they've assessed the contract's usage and safety, and they feel comfortable with it, they can trust that it will always be that way. 

As a sort of emergency eject button, EVM provided the SELFDESTRUCT opcode, which will disable the contract on the blockchain, at the same time withdrawing all funds from it. Usage of SELFDESTRUCT has been controversial, as it's said to break immutability. Also it has obvious implications for rug-pulls. 

Then came upgradeability, which takes it a step further. 

Some technical explanation on upgradeability: there is more than one way to make a contract upgradeable. There are many design patterns, with different features, advantages, and disadvantages. The most popular one seems to be the UUPS - the Universal Upgradeable Proxy Standard. Like many upgradeability patterns, it makes clever use of two features of the EVM bytecode specification: fallback functions (a function that executes on a contract when the specified function selector could not be found) and DELEGATECALL (an arguably dangerous instruction that calls a function of another smart contract, while giving the called contract full access to the calling contract's stored data). In this pattern, the contract with which clients interact is just a proxy, while the real contract that defines the logic used behind the scenes can be switched out at any time for a different contract with different logic. That's analogous to the rental agreement changing completely without the renter's knowledge or consent. When the contract is upgraded, the client is still interacting with the same contract (the proxy) address; they make no conscious choice to switch to the new contract. 

Standard practice for security is to thouroughly audit a smart contract before beginning to use it. This is good practice, and reasonable. This is analogous to fully reading a legal contract from top to bottom before signing it. If a new version of the contract was published (at a new address), one would reasonably repeat that process for the new contract before consciously and intentionally switching to it. However, to guard against the shenanigans described previously, one would have to repeat that process _before each call_ to the contract, and one would not be advised to _store_ tokens or currency in it for any period of time. A big difference.


## An Appropriate Use Case 

The upgradeable patterns have great benefits to the developers and maintainers of smart contracts. I mean, what a relief! We've tested thoroughly, checked and re-checked everything, but we can rest easy knowing that if something _does_ go wrong, we have an out. But for the users of smart contracts? Not so much. I personally would trust such a contract only under one or more of the following circumstances: 

- The contract owner was someone that I _know personally_ and trust well, _and_ not much value is at risk 
- The use of the contract is a pass-through; my money or tokens will be in the contract's control only for the space of a transaction, and then will be somewhere else; _and_ not much value is at risk
- No value is at risk; the contract does something functional but does not handle funds (i.e., it cannot hurt me) 
- The contract requires _my_ vote in order to be upgraded 

Let's look at the last one, because this I think is a very valid use case for upgradeability in blockchain code. Here's an example scenario: 
A group of parents, fed up with what they see as undesirable options for their childrens' educations, decided to get together to form a homeschooling co-op for their kids. They hire some teachers, rent a space, and buy educational equipment, pooling all of their funds, and splitting all costs. Not all parents were on board with paying for everything in crypto, but still a smart contract was deemed useful for making proposals and voting. In this system, enforced by smart contract and made transparent and uncheatable by the blockchain, any participant in the contract could submit a proposal (e.g. "I think we should hire Mr. Nakamoto as a PE instructor" or "I propose that we raise the trachers' salaries by 10%". Proposals reqire a certain ratio of yes to no votes to pass. 

Only registered participants (their addresses stored in the contract) may participate in voting. So this contract is public on the public blockchain, but private is usage (a closed group of users), which is a valid and normal use case. There may be other rules and details as well, like time limits, proposal types, etc., you may well be able to imagine. To avoid any shenanigans caused by logic errors that might render the contract unusable, the contract was made upgradeable. But the caveat was that _all_ contract participants must vote to approve a proposed upgrade. 

The voting logic for the upgrade is separate from the voting logic for normal proposals. It works like this: a contract address is submitted (by any participant) as a candidate for the upgrade. After each particpant has had time to review the new contract, each may vote yes or no for the proposed contract, specifying the contract address in their vote to ensure that the contract they're voting on is indeed the one proposed. After all votes are counted, if the decision is "yes" for the upgrade, the implementation will be switched out for the candidate. The candidate address is cleared. 

```
contract SchoolCoopVoting is UUPSUpgradeable  {
  address public proposedUpgrade = address(0);  
  address[] public participants;
  
  mapping(address => bool) private participantsMapping;
  mapping(address => bool) private proposedUpgradeVotes;
 
  modifier participantOnly {
    require(isParticipant(msg.sender), "Only registered participants may perform this action"); 
    _;
  }
  
  function voteForUpgrade(address upgradeAddr, bool yeaOrNay) external participantOnly {
    require(upgradeAddr == proposedUpgrade, "You are voting for the wrong proposed upgrade"); 
    
    proposedUpgradeVotes(upgradeAddr)(msg.sender) = yeaOrNay; 
  }
  
  function upgradeTo(address upgradeAddr) external participantOnly {
    _doUpgrade(upgradeAddr); 
  }
  
  function upgradeToAndCall(address newImplementation, bytes memory data) external payable override onlyProxy {
    super.upgradeToAndCall(newImplementation, data); 
    afterUpgrade(newImplementation);
  }
  
  function isParticipant(address addr) public returns (bool) {
    return participantsMapping(addr);
  }
  
  function upgradeTo(address newImplementation) external override onlyProxy {
    super.upgradeTo(newImplementation); 
    afterUpgrade(newImplementation);
  }
  
  function _authorizeUpgrade(bool newImplementation) internal override participantOnly {
    require(newImplementation == proposedUpgrade, "Sir, this is a Wendy's"); 
    for(uint256 n=0; n<participants.length(); n++) {
      if (!proposedUpgradeVotes(participants[n])) {
        revert("The upgrade in question has not been approved");
      }
    } 
  }
  
  function afterUpgrade(address /*newImplementation*/) internal {
    proposedUpgrade = address(0); 
    clearMapping(); 
  }
  
  function clearMapping() internal {
    for(uint256 n=0; n<participants.length(); n++) {
      proposedUpgradeVotes(participants[n]) = false;
    }
  }
}
```

It's fair to upgrade to a new implementation if _all participants agree_ to the new implementation. This would only be practical in cases where the number of participants is manageably small. 

## Conclusion
Just because we _can_ do something, doesn't mean that we _should_. Upgradeability is a huge boon to developers, but it breaks something very fundamental behind the entire premise of smart (or even dumb) contracts: immutability. Ironically, even as they give some assurance in the realm of security, they may open up a different kind of security concern. Despite their obvious benefits, there are - in my opinion - narrow use cases for upgradeability in smart contracts. 
