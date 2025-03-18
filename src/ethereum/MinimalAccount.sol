// SPDX-Lisence-Identifier: MIT
pragma solidity 0.8.24; 

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol"; 
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; 
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol"; // formatting changes
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol"; 

contract MinimalAccount is IAccount, Ownable {

    constructor() Ownable(msg.sender) {}
    // entrypoint -> this account  
    // a signature is valid, if it's the minimalAccount owner 
        function validateUserOp(    // validates the signature
        PackedUserOperation calldata userOp,    // hash of the whole operation
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash); 
        _payPrefund(missingAccountFunds); 
    }

    // EIP-191 version of the signed hash 
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash) 
    internal
    view
    returns(uint256 validationData) {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash); // convert to proper format 
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature); // get the signer address from the message hash
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED; // 0
        }
        return SIG_VALIDATION_SUCCESS; // 1 
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if(missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}(""); 
            (success); 
        }
    }
}