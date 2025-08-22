pragma circom 2.1.6;

include "@zk-email/circuits/email-verifier.circom";
include "@zk-email/circuits/utils/array.circom";   // ← correct path
include "regex_vote.circom";

template VoteEmail(MAX_HEADERS, MAX_BODY, N, K, REMOVE_SOFT_LB) {
    component ev = EmailVerifier(MAX_HEADERS, MAX_BODY, N, K, 0, 0, 0, REMOVE_SOFT_LB);

    signal input emailHeader[MAX_HEADERS];
    signal input emailHeaderLength;
    signal input pubkey[K];
    signal input signature[K];
    signal input emailBody[MAX_BODY];
    signal input emailBodyLength;
    signal input bodyHashIndex;
    signal input precomputedSHA[32];
    signal input decodedEmailBodyIn[MAX_BODY]; // since REMOVE_SOFT_LB = 1

    ev.emailHeader <== emailHeader;
    ev.emailHeaderLength <== emailHeaderLength;
    ev.pubkey <== pubkey;
    ev.signature <== signature;
    ev.emailBody <== emailBody;
    ev.emailBodyLength <== emailBodyLength;
    ev.bodyHashIndex <== bodyHashIndex;
    ev.precomputedSHA <== precomputedSHA;
    ev.decodedEmailBodyIn <== decodedEmailBodyIn;

    // From docs: enforce zero padding when ignoreBodyHashCheck = 0
    component pad = AssertZeroPadding(MAX_BODY);
    pad.in <== emailBody;
    pad.startIndex <== emailBodyLength + 1;

    component re = RegexVote(MAX_BODY);
    re.msg <== emailBody;        // <-- input name is msg
    signal output voteIsValid;
    voteIsValid <== re.out;      // <-- output name is out

}
component main = VoteEmail(4096, 8192, 121, 17, 1);
