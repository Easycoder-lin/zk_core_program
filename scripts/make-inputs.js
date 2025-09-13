// scripts/make-inputs.js  (ESM)
import fs from "fs";
import path from "path";
import { buildPoseidon } from "circomlibjs";
import { keccak256, toUtf8Bytes } from "ethers";

const DEPTH = 16; // MUST match the circuit depth you compiled

function findFile(candidates) {
  for (const p of candidates) if (fs.existsSync(p)) return p;
  throw new Error(`File not found. Tried: ${candidates.join(", ")}`);
}

function canonEmail(s) {
  s = s.trim().toLowerCase();
  const m = s.match(/<([^>]+)>/);
  return (m ? m[1] : s).trim();
}

// Keep only the top visible reply (strip quoted thread)
function extractVisibleReply(raw) {
  const lines = raw.split(/\r?\n/);
  const out = [];
  for (const line of lines) {
    if (/^\s*>/.test(line)) break;
    if (/^\s*-{2,}\s*Original Message\s*-{2,}\s*$/i.test(line)) break;
    if (/^\s*On .+wrote:\s*$/i.test(line)) break;
    if (/^\s*在.+写道：\s*$/.test(line)) break;
    if (/^\s*發件人[:：]/.test(line) || /^\s*寄件者[:：]/.test(line)) break;
    if (out.length > 0 && /^\s*(From|Sent|To|Subject):/i.test(line)) break;
    out.push(line);
  }
  return out.join("\n").trim();
}

// Parse multipart/alternative → prefer text/plain
function getPlainTextBody(raw) {
  const m = raw.match(/Content-Type:\s*multipart\/alternative;[^]*?boundary="([^"]+)"/i);
  if (!m) return extractVisibleReply(raw);
  const boundary = m[1];
  const parts = raw.split(new RegExp(`--${boundary}`));
  for (const part of parts) {
    if (/Content-Type:\s*text\/plain/i.test(part)) {
      const i = part.search(/\r?\n\r?\n/);
      const body = i >= 0 ? part.slice(i + (part[i] === "\r" ? 4 : 2)) : part;
      return extractVisibleReply(body);
    }
  }
  return extractVisibleReply(raw);
}

const kBig = (s) => BigInt(keccak256(toUtf8Bytes(s)));
const hexToBig = (h) => BigInt("0x" + h.trim().replace(/^0x/i, ""));

const cwd = process.cwd();

// --- read files ---
const invitePath = findFile([
  path.join(cwd, "Vote Invitation.eml"),
  path.join(cwd, "emls", "Vote Invitation.eml"),
]);
const replyPath = findFile([
  path.join(cwd, "Vote Reply.eml"),
  path.join(cwd, "emls", "Vote Reply.eml"),
]);
const invite = fs.readFileSync(invitePath, "utf8");
const replyRaw = fs.readFileSync(replyPath, "utf8");
const reply = getPlainTextBody(replyRaw);

// --- parse invite ---
const mElection = invite.match(/^\s*Election:\s*(EID-\d{4}-\d{2})/mi);
const mToken = invite.match(/^\s*Token:\s*([A-Fa-f0-9]{64})/mi);
if (!mElection || !mToken) throw new Error("Invite parse failed (need Election + 64-hex Token)");
const electionId = mElection[1];
const tokenHex = mToken[1];

// --- parse reply body ---
if (/\bToken:\s*[A-Fa-f0-9]{64}\b/m.test(reply)) {
  throw new Error("Reply contains Token — reject per rules");
}
const mElectionReply = reply.match(/^\s*Election:\s*(EID-\d{4}-\d{2})/mi);
const mChoice = reply.match(/^\s*Choice:\s*([0-2])/mi);
if (!mElectionReply || !mChoice) throw new Error("Reply parse failed (need Election + Choice)");
if (mElectionReply[1] !== electionId) throw new Error("Election mismatch between invite and reply");
const choice = Number(mChoice[1]);

// From header (full raw)
const mFrom = replyRaw.match(/^\s*From:\s*([^\r\n]+)/mi);
const fromEmail = canonEmail(process.env.FROM || (mFrom ? mFrom[1] : "voter@example.com"));

// === NEW: load real Merkle path built by scripts/build-tree.js ===
const safeName = fromEmail.replace(/\//g, "_"); // guard against slashes in filenames
const pathFile = path.join(cwd, "paths", `${safeName}.json`);
if (!fs.existsSync(pathFile)) {
  throw new Error(`No path file for voter. Expected: ${pathFile}\nRun: node scripts/build-tree.js`);
}
const pathData = JSON.parse(fs.readFileSync(pathFile, "utf8"));

// Sanity checks: depth match + election consistency
if (pathData.pathElements.length !== DEPTH) {
  throw new Error(`Path depth ${pathData.pathElements.length} != circuit DEPTH ${DEPTH}. Rebuild tree or recompile circuit.`);
}
if (!pathData.electionIdHash) {
  throw new Error("paths/<email>.json missing electionIdHash; rebuild the tree with the provided build-tree.js");
}

// --- Poseidon hashing ---
const poseidon = await buildPoseidon();
const F = poseidon.F;

const fromHash = F.toObject(poseidon([kBig(fromEmail)]));
const electionIdHash = F.toObject(poseidon([kBig(electionId)]));
// Ensure tree was built for the same election
if (electionIdHash.toString() !== pathData.electionIdHash) {
  throw new Error("ElectionId hash mismatch between make-inputs and tree. Use the same EID when building the tree.");
}

const token = hexToBig(tokenHex);
const leaf = F.toObject(poseidon([fromHash, token, electionIdHash]));
const nullifier = F.toObject(poseidon([electionIdHash, token]));

// --- use the REAL path/root from paths/<email>.json ---
const pathIndices = pathData.pathIndices;   // array of "0"/"1"
const pathElements = pathData.pathElements; // array of field strings
const merkleRoot = pathData.merkleRoot;

// --- write inputs ---
const vote = {
  merkleRoot: merkleRoot,
  electionIdHash: electionIdHash.toString(),
  choice: choice.toString(),
  nullifier: nullifier.toString(),
  fromHash: fromHash.toString(),
  token: token.toString(),
  pathElements,
  pathIndices,
};
fs.writeFileSync("vote.json", JSON.stringify(vote, null, 2));

const pub = {
  merkleRoot: vote.merkleRoot,
  electionIdHash: vote.electionIdHash,
  choice: vote.choice,
  nullifier: vote.nullifier,
};
fs.writeFileSync("public.json", JSON.stringify(pub, null, 2));

console.log("Wrote vote.json and public.json (real Merkle path)");
