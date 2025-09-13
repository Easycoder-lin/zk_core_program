# zkEmail Voting Demo

This project provides a **zero-knowledge email voting** system. Voters receive an invite with a secret token, and reply with only their choice. A **zkSNARK circuit** is used to prove a voter's eligibility without revealing their identity or token. The repository includes **Circom circuits**, input builders, and scripts to generate and verify proofs.

---

## Repo Layout

* **`circuits/`**: Circom circuits, including `vote-email.circom` and `regex_vote.circom`.
* **`emls/`**: Sample invite and reply emails (ignored by git).
* **`paths/`**: Per-voter Merkle authentication paths (ignored by git).
* **`scripts/`**: Helper scripts for building the Merkle tree, making inputs, etc.
* **`tools/`**: Compiled circuit artifacts (ignored by git).

---

## Prerequisites

* Node.js ≥ 18
* [circom](https://docs.circom.io/getting-started/installation/) ≥ 2.2.2
* [snarkjs](https://github.com/iden3/snarkjs)

To install local dependencies, run:

```bash
npm install
```

## Workflow
**1. Build allowlist & Merkle tree**<br>
First, you need to create an ```allowlist.csv``` file. This file contains the email and a secret token for each eligible voter.
```
email,token
alice@example.com,9F7C3A...ABCDE
bob@example.com,12ab34...9f0c
```
Next, generate the **Merkle root** and a unique path for each voter by running the following script.
```bash
node scripts/build-tree.js
```
This command will create ```tree.json``` and a separate file for each voter in the ```paths/``` directory (e.g., ```paths/alice@example.com.json```).

---

**2. Parse voter reply → build inputs**<br>
Place the invite and reply emails in the ```emls/``` directory. Then, generate the circuit's input files, ```vote.json``` and ```public.json```, by running:
```bash
npm run inputs
```
---
**3. Compile circuit**<br>
Compile the Circom circuit into the necessary artifacts for proof generation:
```bash
npm run compile
```
---

**4. Setup trusted ceremony**<br>
Run the Powers of Tau ceremony and prepare phase 2:
```bash
npm run ptau15
```
Then generate the proving/verification keys:
```bash
npm run setup
```
---

**5. Prove & verify locally**<br>
**- Witness**
```bash
npm run witness
```

**- Proof**
```bash
npm run prove
```

**- Verify**
```bash
npm run verify
```
You should see:
```csharp
[INFO] snarkJS: OK!
```

**6. Full demo (one command)**<br>
You can run the full flow (compile → inputs → witness → setup → prove → verify) with:
```bash
npm run demo
```

---

**.gitignore**<br>
This repository ignores the following files and directories to protect sensitive data and keep the repository clean:
- ```node_modules/```
- **Compiled artifacts:** ```.ptau```, ```.zkey```, ```.r1cs```, ```.wtns```, ```.wasm```, etc.
- **Secrets**: ```.eml``` files, ```allowlist.csv```, ```paths/*.json```
- **Generated proofs**: ```proof.json```, ```public.json```

---

**Security Notes**
- Do not commit **sensitive files** like ```.eml``` files, ```allowlist.csv```, or Merkle paths, as they contain private voter information.

- Always perform a **fresh trusted setup** before using this system in a production environment.

- This demo is for **research and educational purposes only** and is not production-ready.

---

## License
MIT