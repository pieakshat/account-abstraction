// SPDX-Lisence-Identifier: MIT
pragma solidity 0.8.24; 

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol"; 
import {DeployMinimal} from "scripts/DeployMinimal.s.sol"; 
import {HelperConfig} from "scripts/HelperConfig.s.sol"; 
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOp, IEntryPoint} from "script/SendPackedUserOp.s.sol"; 
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32

    HelperConfig helperConfig; 
    MinimalAccount minimalAccount; 
    ERC20Mock usdc; 
    SendPackedUserOp sendPackedUserOp

    address randomUser = makeAddr("randomUser"); 

    uint256 AMOUNT = 1e18; 


    function setUp() public {
        DeployMinimal deployMinimal = new DeployMinimal(); 
        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount(); 
        usdc = new ERC20Mock();  
        sendPackedUserOp = new sendPackedUserOp(); 
    }

    // USDC Approval 
    // msg.sender -> MinimalAccount
    // approve some amount 
    // USDC contract 
    // come from the entrypoint 

    function testOwnerCanExecuteCommands() public {
        // Arrange 
        assertEq(usdc.balanceOf(address(minimalAccount)), 0); 
        address dest = address(usdc); 
        uint256 value = 0; 
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        // Act 
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, functionData);


        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT); 


    }

    function testNonOwnerCannotExecute() public {
        // Arrange 
        assertEq(usdc.balanceOf(address(minimalAccount)), 0); 
        address dest = address(usdc); 
        uint256 value = 0; 
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        // Act 
        vm.prank(randomUser);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(dest, value, functionData);
        
    }

    function testRecoverSignedOp() public view {
        // arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0); 
        address dest = address(usdc); 
        uint256 value = 0; 
        // now we wrap the above three things in functionData
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT); 
        // now we wrap the above four lines in callData
        bytes memory executeCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);

        PackedUserOperation packedUserOp = sendPackedUserOp.generateSignedUserOperation(executeCallData, 
        helperConfig.getConfig()); 
        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHas(packedUserOp); 

        // act 
        address actualSigner = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), packedUserOp.signature); 

        assertEq(actualSigner, minimalAccount.owner()); 
        //assert
    }

}