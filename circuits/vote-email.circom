pragma circom 2.2.2;

include "circomlib/circuits/poseidon.circom";
include "./regex_vote.circom";

// Binary Poseidon Merkle inclusion
template MerkleVerify(depth) {
    // ---- inputs ----
    signal input root;                 // public
    signal input leaf;                 // private
    signal input pathElements[depth];  // private
    signal input pathIndices[depth];   // private (0 = left, 1 = right)

    // booleanize indices
    for (var i = 0; i < depth; i++) {
        pathIndices[i] * (pathIndices[i] - 1) === 0;
    }

    // We'll keep the running node as an array (no re-assignment of the same signal)
    signal cur[depth + 1];
    cur[0] <== leaf;

    // Predeclare components and intermediate signals outside the loop
    component H[depth];

    // For input[0] = (1 - b)*cur + b*elt
    signal oneMinus[depth];
    signal sel0_left[depth];
    signal sel0_right[depth];

    // For input[1] = b*cur + (1 - b)*elt
    signal sel1_left[depth];
    signal sel1_right[depth];

    for (var j = 0; j < depth; j++) {
        H[j] = Poseidon(2);

        // oneMinus[j] = 1 - pathIndices[j]
        // (linear constraint; allowed)
        oneMinus[j] <== 1 - pathIndices[j];

        // ---- input[0] wiring with separate quadratic constraints ----
        sel0_left[j]  <== oneMinus[j]   * cur[j];          // one product
        sel0_right[j] <== pathIndices[j] * pathElements[j]; // one product
        H[j].inputs[0] <== sel0_left[j] + sel0_right[j];    // linear sum

        // ---- input[1] wiring ----
        sel1_left[j]  <== pathIndices[j] * cur[j];          // one product
        sel1_right[j] <== oneMinus[j]    * pathElements[j]; // one product
        H[j].inputs[1] <== sel1_left[j] + sel1_right[j];    // linear sum

        // advance
        cur[j + 1] <== H[j].out;
    }

    // must match root
    root === cur[depth];
}

// Public:  merkleRoot, electionIdHash, choice, nullifier (= Poseidon(electionIdHash, token))
// Private: fromHash, token, merkle path
template VoteEmail(depth) {
    // PUBLIC
    signal input merkleRoot;
    signal input electionIdHash;
    signal input choice;
    signal input nullifier;

    // PRIVATE
    signal input fromHash;
    signal input token;
    signal input pathElements[depth];
    signal input pathIndices[depth];

    // 1) choice ∈ {0,1,2}
    component C = ChoiceCheck();
    C.choice <== choice;

    // 2) nullifier = Poseidon(electionIdHash, token)
    component N = Poseidon(2);
    N.inputs[0] <== electionIdHash;
    N.inputs[1] <== token;
    nullifier === N.out;

    // 3) leaf = Poseidon(fromHash, token, electionIdHash)
    component L = Poseidon(3);
    L.inputs[0] <== fromHash;
    L.inputs[1] <== token;
    L.inputs[2] <== electionIdHash;

    // 4) Merkle inclusion
    component M = MerkleVerify(depth);
    M.leaf <== L.out;
    for (var i = 0; i < depth; i++) {
        M.pathElements[i] <== pathElements[i];
        M.pathIndices[i]  <== pathIndices[i];
    }
    M.root <== merkleRoot;
}

// Adjust depth as needed
component main = VoteEmail(16);
