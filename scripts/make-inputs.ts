import fs from "fs";
import { generateEmailVerifierInputs } from "@zk-email/helpers";

async function main() {
  const eml = fs.readFileSync("./emls/reply.eml");
  const inputs = await generateEmailVerifierInputs(eml, {
    maxHeadersLength: 4096,
    maxBodyLength: 8192, // ← bump this to match circuit
    ignoreBodyHashCheck: false,
    removeSoftLineBreaks: true, // keep; helps with quoted-printable wraps
    shaPrecomputeSelector: "vote:",
  });

  // write input.json for the Circom witness generator
  fs.writeFileSync("./build/input.json", JSON.stringify(inputs));
}
main().catch((e) => {
  console.error(e);
  process.exit(1);
});
