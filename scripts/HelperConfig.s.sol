// SPDX-Lisence-Identifier: MIT
pragma solidity 0.8.24; 

import {Script, console} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol"; 

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId(); 

    struct NetworkConfig {
        address entryPoint; 
        address account; 
    }

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111; 
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;  
    address constant BURNER_WALLET = 0x7144b814a473017612Ac9f6Bbd287147e500953F; 
    address constant FOUNDRY_DEFAULT_WALLET = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    NetworkConfig public localNetworkConfig; 
    mapping(uint256 chainId => NetworkConfig) public networkConfigs; 
    //  0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig(); 
    }

    function getConfig() public returns(NetworkConfig memory) {
        return getConfigByChainId(block.chainid); 
    }

    function getConfigByChainId(uint256 chainId) public returns(NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].entryPoint != address(0)){
            return networkConfigs[chainId]; 
        } else {
            revert HelperConfig__InvalidChainId(); 
        }
    }

    function getEthSepoliaConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig({entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789, account: BURNER_WALLET}); 
    }

    function getZKSyncSepoliaConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});  
    }

    function getOrCreateAnvilEthConfig() public returns(NetwosrkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig; 
        }
    
    // deploy mocks 
    console2.log("Deploying mocks..."); 
    vm.startBroadcast(FOUNDRY_DEFAULT_WALLET);
    EntryPoint entryPoint = new EntryPoint(); 
    
    vm.stopBroadcast();

    return NetworkConfig({entryPoint: address(0), account: FOUNDRY_DEFAULT_WALLET}); 
    }

    

    
} 