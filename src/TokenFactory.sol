// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/* 
* @title TokenFactory
* @dev Allows the owner to deploy new ERC20 contracts
* @dev This contract will be deployed on both an L1 & an L2
*/
contract TokenFactory is Ownable {
    mapping(string tokenSymbol => address tokenAddress) private s_tokenToAddress;

    event TokenDeployed(string symbol, address addr);

    constructor() Ownable(msg.sender) { }

    /*
     * @dev Deploys a new ERC20 contract
     * @param symbol The symbol of the new token
     * @param contractBytecode The bytecode of the new token
     */
    function deployToken(string memory symbol, bytes memory contractBytecode) public onlyOwner returns (address addr) {
        // q are you sure you want this out of scope ? 
        // maybe this is a gas efficient way to do it
        assembly {
            // @audit : this wont work with zk sync !!
            // test this on zksync
            // X large 
            // load the contract bytecdoe into memory 
            // create a contract 
            addr := create(0, add(contractBytecode, 0x20), mload(contractBytecode))
        } // gives the lower leve laccess to the EVM
        // here we are creating a yul function that will create a new contract
        s_tokenToAddress[symbol] = addr;
        emit TokenDeployed(symbol, addr);
    }

    function getTokenAddressFromSymbol(string memory symbol) public view returns (address addr) {
        return s_tokenToAddress[symbol];
    }
}
