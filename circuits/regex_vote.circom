pragma circom 2.2.2;

// choice ∈ {0,1,2} using only quadratic constraints
template ChoiceCheck() {
    signal input choice;
    signal a;
    a <== choice * (choice - 1);   // one product
    a * (choice - 2) === 0;        // one product
}

// Optional flag if you want to pass an off-circuit "no token present" check
template NoTokenFlag() {
    signal input noToken; // must be 1
    noToken * (noToken - 1) === 0;
    noToken === 1;
}
