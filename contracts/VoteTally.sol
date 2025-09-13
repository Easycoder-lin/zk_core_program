// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Verifier.sol";

/**
 * Public signals order must be:
 * [merkleRoot, electionIdHash, choice, nullifier]
 */
contract VoteTally {
    Verifier public verifier;
    uint256 public merkleRoot;
    uint256 public electionIdHash;
    uint256[3] public tally;
    mapping(uint256 => bool) public nullifierUsed;

    event VoteCounted(uint256 choice, uint256 nullifier);

    constructor(address _verifier, uint256 _root, uint256 _electionIdHash) {
        verifier = Verifier(_verifier);
        merkleRoot = _root;
        electionIdHash = _electionIdHash;
    }

    function submitVote(
        uint[2] calldata a,
        uint[2][2] calldata b,
        uint[2] calldata c,
        uint256[4] calldata input   // [root, eid, choice, nullifier]
    ) external {
        require(input[0] == merkleRoot, "wrong root");
        require(input[1] == electionIdHash, "wrong election");
        require(input[2] < 3, "bad choice");
        require(!nullifierUsed[input[3]], "double vote");

        uint256;
        for (uint i = 0; i < 4; i++) din[i] = input[i];
        require(verifier.verifyProof(a, b, c, din), "invalid proof");

        nullifierUsed[input[3]] = true;
        tally[input[2]] += 1;
        emit VoteCounted(input[2], input[3]);
    }
}
