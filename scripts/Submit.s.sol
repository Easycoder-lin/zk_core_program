// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/StdJson.sol";
import "../contracts/VoteTally.sol";

contract Submit is Script {
    using stdJson for string;

    function _u(string memory s) internal pure returns (uint256 v) {
        bytes memory b = bytes(s);
        for (uint i; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            require(c >= 48 && c <= 57, "non-decimal");
            v = v * 10 + (c - 48);
        }
    }

    function run(address tallyAddr) external {
        string memory proof = vm.readFile("tools/proof.json");
        string memory pub   = vm.readFile("tools/public.json"); // array

        // a
        uint[2] memory a = [
            _u(proof.readString(".pi_a[0]")),
            _u(proof.readString(".pi_a[1]"))
        ];

        // b  ([[b00,b01],[b10,b11]])  — matches snarkjs' verifier mapping
        uint[2][2] memory b = [
            [_u(proof.readString(".pi_b[0][0]")), _u(proof.readString(".pi_b[0][1]"))],
            [_u(proof.readString(".pi_b[1][0]")), _u(proof.readString(".pi_b[1][1]"))]
        ];

        // c
        uint[2] memory c = [
            _u(proof.readString(".pi_c[0]")),
            _u(proof.readString(".pi_c[1]"))
        ];

        // public input [root, eid, choice, nullifier]
        uint256[4] memory input = [
            _u(pub.readString(".0")),
            _u(pub.readString(".1")),
            _u(pub.readString(".2")),
            _u(pub.readString(".3"))
        ];

        vm.startBroadcast();
        VoteTally tally = VoteTally(tallyAddr);
        tally.submitVote(a, b, c, input);
        vm.stopBroadcast();
    }
}
