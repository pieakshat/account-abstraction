// SPDX-Lisence-Identifier: MIT
pragma solidity 0.8.24; 

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Scripts {
    error HelperConfig__InvalidChainId(); 

    struct NetworkConfig {
        address entryPoint; 
    }

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111; 
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300; 

    NetworkConfig public localNetworkConfig; 
    mapping(uint256 chainId => NetworkConfig) public networkConfigs; 
    //  0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig(); 
    }

    function getEthSepoliaConfig() public pure returns(networkConfig memory) {
        return NetworkConfig({entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789}); 
    }

    function getZKSyncSepoliaConfig() public pure returns(networkConfig memory) {
        return NetworkConfig({entryPoint: address(0)});  
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        if (localNetworkConfig.entryPoint != address(0)) {
            return localNetworkConfig; 
        }
    }

    // deploy a mock entrypoint contract 
} 