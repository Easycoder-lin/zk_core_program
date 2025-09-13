// scripts/make-allowlist.js (ESM)
import fs from "fs";

const invite = fs.readFileSync("./emls/Vote Invitation.eml", "utf8");
const reply  = fs.readFileSync("./emls/Vote Reply.eml", "utf8");

// token from invite
const mTok = invite.match(/^\s*Token:\s*([A-Fa-f0-9]{64})/mi);
if (!mTok) throw new Error("Token not found in Vote Invitation.eml");
const token = mTok[1];

// sender email from reply
const mFrom = reply.match(/^\s*From:\s*([^\r\n]+)/mi);
if (!mFrom) throw new Error("From header not found in Vote Reply.eml");
const emailLine = mFrom[1].trim();
const mAngle = emailLine.match(/<([^>]+)>/);
const email = (mAngle ? mAngle[1] : emailLine).trim().toLowerCase();

fs.writeFileSync("allowlist.csv", `email,token\n${email},${token}\n`);
console.log("Wrote allowlist.csv with 1 row:", email);
