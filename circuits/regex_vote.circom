pragma circom 2.1.5;

include "@zk-email/zk-regex-circom/circuits/regex_helpers.circom";

// regex: vote:(alice|bob|carol)
template RegexVote(msg_bytes) {
	signal input msg[msg_bytes];
	signal output out;

	var num_bytes = msg_bytes+1;
	signal in[num_bytes];
	signal in_range_checks[msg_bytes];
	in[0]<==255;
	for (var i = 0; i < msg_bytes; i++) {
		in_range_checks[i] <== LessThan(8)([msg[i], 255]);
		in_range_checks[i] === 1;
		in[i+1] <== msg[i];
	}

	component eq[11][num_bytes];
	component and[18][num_bytes];
	component multi_or[1][num_bytes];
	signal states[num_bytes+1][17];
	signal states_tmp[num_bytes+1][17];
	signal from_zero_enabled[num_bytes+1];
	from_zero_enabled[num_bytes] <== 0;
	component state_changed[num_bytes];

	for (var i = 1; i < 17; i++) {
		states[0][i] <== 0;
	}

	for (var i = 0; i < num_bytes; i++) {
		state_changed[i] = MultiOR(16);
		states[i][0] <== 1;
		eq[0][i] = IsEqual();
		eq[0][i].in[0] <== in[i];
		eq[0][i].in[1] <== 118;
		and[0][i] = AND();
		and[0][i].a <== states[i][0];
		and[0][i].b <== eq[0][i].out;
		states_tmp[i+1][1] <== 0;
		eq[1][i] = IsEqual();
		eq[1][i].in[0] <== in[i];
		eq[1][i].in[1] <== 111;
		and[1][i] = AND();
		and[1][i].a <== states[i][1];
		and[1][i].b <== eq[1][i].out;
		states[i+1][2] <== and[1][i].out;
		eq[2][i] = IsEqual();
		eq[2][i].in[0] <== in[i];
		eq[2][i].in[1] <== 116;
		and[2][i] = AND();
		and[2][i].a <== states[i][2];
		and[2][i].b <== eq[2][i].out;
		states[i+1][3] <== and[2][i].out;
		eq[3][i] = IsEqual();
		eq[3][i].in[0] <== in[i];
		eq[3][i].in[1] <== 101;
		and[3][i] = AND();
		and[3][i].a <== states[i][3];
		and[3][i].b <== eq[3][i].out;
		states[i+1][4] <== and[3][i].out;
		eq[4][i] = IsEqual();
		eq[4][i].in[0] <== in[i];
		eq[4][i].in[1] <== 58;
		and[4][i] = AND();
		and[4][i].a <== states[i][4];
		and[4][i].b <== eq[4][i].out;
		states[i+1][5] <== and[4][i].out;
		eq[5][i] = IsEqual();
		eq[5][i].in[0] <== in[i];
		eq[5][i].in[1] <== 97;
		and[5][i] = AND();
		and[5][i].a <== states[i][5];
		and[5][i].b <== eq[5][i].out;
		states[i+1][6] <== and[5][i].out;
		eq[6][i] = IsEqual();
		eq[6][i].in[0] <== in[i];
		eq[6][i].in[1] <== 98;
		and[6][i] = AND();
		and[6][i].a <== states[i][5];
		and[6][i].b <== eq[6][i].out;
		states[i+1][7] <== and[6][i].out;
		eq[7][i] = IsEqual();
		eq[7][i].in[0] <== in[i];
		eq[7][i].in[1] <== 99;
		and[7][i] = AND();
		and[7][i].a <== states[i][5];
		and[7][i].b <== eq[7][i].out;
		states[i+1][8] <== and[7][i].out;
		eq[8][i] = IsEqual();
		eq[8][i].in[0] <== in[i];
		eq[8][i].in[1] <== 108;
		and[8][i] = AND();
		and[8][i].a <== states[i][6];
		and[8][i].b <== eq[8][i].out;
		states[i+1][9] <== and[8][i].out;
		and[9][i] = AND();
		and[9][i].a <== states[i][7];
		and[9][i].b <== eq[1][i].out;
		states[i+1][10] <== and[9][i].out;
		and[10][i] = AND();
		and[10][i].a <== states[i][8];
		and[10][i].b <== eq[5][i].out;
		states[i+1][11] <== and[10][i].out;
		eq[9][i] = IsEqual();
		eq[9][i].in[0] <== in[i];
		eq[9][i].in[1] <== 105;
		and[11][i] = AND();
		and[11][i].a <== states[i][9];
		and[11][i].b <== eq[9][i].out;
		states[i+1][12] <== and[11][i].out;
		and[12][i] = AND();
		and[12][i].a <== states[i][10];
		and[12][i].b <== eq[6][i].out;
		and[13][i] = AND();
		and[13][i].a <== states[i][15];
		and[13][i].b <== eq[3][i].out;
		and[14][i] = AND();
		and[14][i].a <== states[i][16];
		and[14][i].b <== eq[8][i].out;
		multi_or[0][i] = MultiOR(3);
		multi_or[0][i].in[0] <== and[12][i].out;
		multi_or[0][i].in[1] <== and[13][i].out;
		multi_or[0][i].in[2] <== and[14][i].out;
		states[i+1][13] <== multi_or[0][i].out;
		eq[10][i] = IsEqual();
		eq[10][i].in[0] <== in[i];
		eq[10][i].in[1] <== 114;
		and[15][i] = AND();
		and[15][i].a <== states[i][11];
		and[15][i].b <== eq[10][i].out;
		states[i+1][14] <== and[15][i].out;
		and[16][i] = AND();
		and[16][i].a <== states[i][12];
		and[16][i].b <== eq[7][i].out;
		states[i+1][15] <== and[16][i].out;
		and[17][i] = AND();
		and[17][i].a <== states[i][14];
		and[17][i].b <== eq[1][i].out;
		states[i+1][16] <== and[17][i].out;
		from_zero_enabled[i] <== MultiNOR(16)([states_tmp[i+1][1], states[i+1][2], states[i+1][3], states[i+1][4], states[i+1][5], states[i+1][6], states[i+1][7], states[i+1][8], states[i+1][9], states[i+1][10], states[i+1][11], states[i+1][12], states[i+1][13], states[i+1][14], states[i+1][15], states[i+1][16]]);
		states[i+1][1] <== MultiOR(2)([states_tmp[i+1][1], from_zero_enabled[i] * and[0][i].out]);
		state_changed[i].in[0] <== states[i+1][1];
		state_changed[i].in[1] <== states[i+1][2];
		state_changed[i].in[2] <== states[i+1][3];
		state_changed[i].in[3] <== states[i+1][4];
		state_changed[i].in[4] <== states[i+1][5];
		state_changed[i].in[5] <== states[i+1][6];
		state_changed[i].in[6] <== states[i+1][7];
		state_changed[i].in[7] <== states[i+1][8];
		state_changed[i].in[8] <== states[i+1][9];
		state_changed[i].in[9] <== states[i+1][10];
		state_changed[i].in[10] <== states[i+1][11];
		state_changed[i].in[11] <== states[i+1][12];
		state_changed[i].in[12] <== states[i+1][13];
		state_changed[i].in[13] <== states[i+1][14];
		state_changed[i].in[14] <== states[i+1][15];
		state_changed[i].in[15] <== states[i+1][16];
	}

	component is_accepted = MultiOR(num_bytes+1);
	for (var i = 0; i <= num_bytes; i++) {
		is_accepted.in[i] <== states[i][13];
	}
	out <== is_accepted.out;
	signal is_consecutive[msg_bytes+1][3];
	is_consecutive[msg_bytes][2] <== 0;
	for (var i = 0; i < msg_bytes; i++) {
		is_consecutive[msg_bytes-1-i][0] <== states[num_bytes-i][13] * (1 - is_consecutive[msg_bytes-i][2]) + is_consecutive[msg_bytes-i][2];
		is_consecutive[msg_bytes-1-i][1] <== state_changed[msg_bytes-i].out * is_consecutive[msg_bytes-1-i][0];
		is_consecutive[msg_bytes-1-i][2] <== ORAnd()([(1 - from_zero_enabled[msg_bytes-i+1]), states[num_bytes-i][13], is_consecutive[msg_bytes-1-i][1]]);
	}
	// substrings calculated: [{(5, 6), (5, 7), (5, 8), (6, 9), (7, 10), (8, 11), (9, 12), (10, 13), (11, 14), (12, 15), (14, 16), (15, 13), (16, 13)}]
	signal prev_states0[13][msg_bytes];
	signal is_substr0[msg_bytes];
	signal is_reveal0[msg_bytes];
	signal output reveal0[msg_bytes];
	for (var i = 0; i < msg_bytes; i++) {
		 // the 0-th substring transitions: [(5, 6), (5, 7), (5, 8), (6, 9), (7, 10), (8, 11), (9, 12), (10, 13), (11, 14), (12, 15), (14, 16), (15, 13), (16, 13)]
		prev_states0[0][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][5];
		prev_states0[1][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][5];
		prev_states0[2][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][5];
		prev_states0[3][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][6];
		prev_states0[4][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][7];
		prev_states0[5][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][8];
		prev_states0[6][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][9];
		prev_states0[7][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][10];
		prev_states0[8][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][11];
		prev_states0[9][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][12];
		prev_states0[10][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][14];
		prev_states0[11][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][15];
		prev_states0[12][i] <== (1 - from_zero_enabled[i+1]) * states[i+1][16];
		is_substr0[i] <== MultiOR(13)([prev_states0[0][i] * states[i+2][6], prev_states0[1][i] * states[i+2][7], prev_states0[2][i] * states[i+2][8], prev_states0[3][i] * states[i+2][9], prev_states0[4][i] * states[i+2][10], prev_states0[5][i] * states[i+2][11], prev_states0[6][i] * states[i+2][12], prev_states0[7][i] * states[i+2][13], prev_states0[8][i] * states[i+2][14], prev_states0[9][i] * states[i+2][15], prev_states0[10][i] * states[i+2][16], prev_states0[11][i] * states[i+2][13], prev_states0[12][i] * states[i+2][13]]);
		is_reveal0[i] <== MultiAND(3)([out, is_substr0[i], is_consecutive[i][2]]);
		reveal0[i] <== in[i+1] * is_reveal0[i];
	}
}