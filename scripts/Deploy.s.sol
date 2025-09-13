// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/StdJson.sol";
import "../contracts/Verifier.sol";
import "../contracts/VoteTally.sol";

contract Deploy is Script {
    using stdJson for string;

    // decimal string -> uint
    function _u(string memory s) internal pure returns (uint256 v) {
        bytes memory b = bytes(s);
        for (uint i; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            require(c >= 48 && c <= 57, "non-decimal");
            v = v * 10 + (c - 48);
        }
    }

    function run() external returns (address verifier, address tally) {
        string memory pub = vm.readFile("tools/public.json"); // array: [root,eid,choice,nullifier]
        uint256 root = _u(pub.readString(".0"));
        uint256 eid  = _u(pub.readString(".1"));

        vm.startBroadcast();
        Verifier v = new Verifier();
        VoteTally t = new VoteTally(address(v), root, eid);
        vm.stopBroadcast();

        console2.log("Verifier:", address(v));
        console2.log("VoteTally:", address(t));
    }
}
