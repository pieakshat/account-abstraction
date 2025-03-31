// SPDX-Lisence-Identifier: MIT
pragma solidity 0.8.24; 

import {Script} from "forge-std/Script.sol"; 
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol"; 
import {NetworkConfig} from "script/HelperConfig.s.sol"; 
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol"; 
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol"; 
contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32; 
    function run() public {

    }

    function generateSignedUserOperation(bytes memory callData, HelperConfig.NetworkConfig memory config) public returns (PackedUserOperation memory) {
        // generate the unsigned data 
        uint256 nonce = vm.getNonce(sender);
        PackedUserOperation memory userOp = _generateUnsignedUserOperation(
            callData, 
            config.account, 
            nonce 
        );

        // Get the userOp hash
        bytes32 userOpHash =  IEntryPoint(config.entryPoint).getUserOpHash(userOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();  

        // sign it and then return it 
        // to sign this we need to get the userOperation hash that the entryPoint contract is looking for 
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(config.account, digest);
        unsignedUserOp.signature = abi.encodePacked(r, s, v); 
        return userOp; 
    }

    function _generateUnsignedUserOperation(bytes memory callData, address sender, uint256 nonce) internal pure returns(PackedUserOperation memory) {
        uint128 verificationGasLimit = 16777216; 
        uint128 callGasLimit = verificationGasLimit; 
        uint128 maxPriorityFeePerGas = 256; 
        uint128 maxFeePer = maxPriorityFeePerGas; 

        // generate the unsigned data 
        return PackedUserOperation({
            sender: sender, 
            nonce: nonce, 
            initCode: hex"", 
            callData: callData, 
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit), 
            preVerificationGas: verificationGasLimit, 
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas), 
            paymasterAndData: hex"", 
            signature: hex""
        }); 
    }
}