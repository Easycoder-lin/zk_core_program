// scripts/build-tree.js (ESM)
import fs from "fs";
import { buildPoseidon } from "circomlibjs";
import { keccak256, toUtf8Bytes } from "ethers";

const DEPTH = 16;                       // keep in sync with circuit
const ELECTION = process.env.ELECTION || "EID-2025-09";

const canon = s => (s||"").trim().toLowerCase();
const kbig  = s => BigInt(keccak256(toUtf8Bytes(s)));
const hexToBig = h => BigInt("0x" + h.replace(/^0x/i, ""));

const csv = fs.readFileSync("allowlist.csv", "utf8").trim().split(/\r?\n/).slice(1);
const rows = csv.map(l => {
  const [email, token] = l.split(",").map(x=>x.trim());
  return { email: canon(email), token: hexToBig(token) };
});

const poseidon = await buildPoseidon();
const F = poseidon.F;

const electionIdHash = F.toObject(poseidon([kbig(ELECTION)]));

// leaves: Poseidon(hashEmail, token, electionIdHash)
const leaves = rows.map(r => {
  const fromHash = F.toObject(poseidon([kbig(r.email)]));
  return { email: r.email, token: r.token, leaf: F.toObject(poseidon([fromHash, r.token, electionIdHash])) };
});

// pad to 2^DEPTH with zeros
const N = 1 << DEPTH;
const pads = Array(Math.max(0, N - leaves.length)).fill({ email: "", token: 0n, leaf: 0n });
const layer0 = [...leaves, ...pads].map(x => x.leaf);

function hash2(a,b){ return F.toObject(poseidon([a,b])); }

// build tree
const layers = [layer0];
for (let d = 0; d < DEPTH; d++) {
  const prev = layers[d];
  const next = [];
  for (let i = 0; i < prev.length; i += 2) next.push(hash2(prev[i], prev[i+1]));
  layers.push(next);
}
const root = layers[DEPTH][0];

// auth path for each real leaf
fs.mkdirSync("paths", { recursive: true });
leaves.forEach((node, idx) => {
  const pathElements = [];
  const pathIndices  = [];
  let i = idx;
  for (let d = 0; d < DEPTH; d++) {
    const isRight = i & 1;
    const sib = layers[d][isRight ? i-1 : i+1];
    pathElements.push(sib.toString());
    pathIndices.push(isRight.toString()); // '0' left, '1' right
    i = i >> 1;
  }
  fs.writeFileSync(`paths/${node.email}.json`, JSON.stringify({ 
    merkleRoot: root.toString(),
    electionIdHash: electionIdHash.toString(),
    pathElements, pathIndices
  }, null, 2));
});

fs.writeFileSync("tree.json", JSON.stringify({
  merkleRoot: root.toString(),
  electionIdHash: electionIdHash.toString(),
  count: leaves.length,
  depth: DEPTH
}, null, 2));

console.log("Built tree:", "root=", root.toString(), "count=", leaves.length);
