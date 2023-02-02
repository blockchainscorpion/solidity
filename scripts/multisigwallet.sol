// SPDX-License-Identifier:MIT

pragma solidity 0.8.13;

contract multisig{

    // List of owners & Variables
    address[] public owners;      
    mapping(address => bool) public ownerList;
    mapping(uint => mapping(address => bool)) public alreadyVoted;
    uint public approvalIsNeeded = 2;

   // Ability to receive funds
    receive() external payable{}

    modifier onlyOwner{
        require(ownerList[msg.sender] == true, "Only an owner can do this");
        _;
    }

    constructor(){
        owners.push(msg.sender);
        ownerList[msg.sender] = true;

        owners.push(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        ownerList [0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = true;
    }

    // Ability to propose a transaction

    struct Transaction{
        address sendingTo;
        uint value;
        bool alreadyExecuted;
        uint approvals;
    }

    Transaction[] public proposedTransactions;   

    function proposeTx(address to, uint amount) public onlyOwner {

        proposedTransactions.push(Transaction({
            sendingTo: to,
            value: amount,
            alreadyExecuted: false,
            approvals: 0
        }));

    }

    // Vote on transaction

    function voteOnTransaction(uint index) public onlyOwner {
        require(alreadyVoted[index][msg.sender] == false, "You've already voted");
        proposedTransactions[index].approvals += 1;
        alreadyVoted[index][msg.sender] = true;
    }

    function executeTx(uint index) public onlyOwner {
        require(proposedTransactions[index].approvals >= approvalIsNeeded, "Note enough votes");
        address payable toSend = payable(proposedTransactions[index].sendingTo);
        (bool tryToSend,) = toSend.call{value: proposedTransactions[index].value, gas: 5000}("");
        require(tryToSend, "not enough eth");
        proposedTransactions[index].alreadyExecuted = true;
    }



}