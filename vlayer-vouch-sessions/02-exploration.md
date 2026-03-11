# Session 1: Initial Exploration

**Date**: 2026-03-10
**Project**: vlayer/vouch
**Branch**: main
**Focus**: Understanding the codebase and how `verifyWebProof` / tlsn-wasm works
**Session ID**: `f3c77c73`

---

### User

Read README.md and scan the repository. Briefly summarize:

- Project purpose
- Tech stack
- Directory structure
- Key files and entry points

## Beads (if available)

Check if beads is initialized in this project (look for `.beads/` directory). If present:

1. Run `bd status` — show project overview (issue counts, prefix)
2. Run `bd ready` — list issues ready to work on (open, no blockers)
3. Briefly summarize what's tracked and what's available to pick up

If beads is not initialized, skip thi

[...truncated]

---

### Claude

Here's the session summary:

## Vouch Monorepo — Zero-Knowledge Web Proofs

**Purpose**: Platform for generating cryptographic proofs of private web data using TLSN (TLS Notarization). Users prove they have certain data without revealing it.

**Tech stack**: pnpm workspace + Turborepo, Next.js 15 (App Router), React 19, TypeScript, Tailwind/DaisyUI, Drizzle ORM + PostgreSQL, Vite (extension), Rust (core proving/crypto), Swift/Kotlin (mobile).

**Directory structure**:
```
apps/
  vouch/              — Main Next.js web app (dashboard, proof flows, API)
  browser-extension/  — Chrome extension for web proof generation (TLSN)
  docs/               — Fumadocs documentation site
  ios/, android/      — Native mobile apps
  web-prover-server/  — Server-side prover
  stream-proxy/       — Proxy server
  decode-cli/         — CLI decoding tool

packages/
  common/             — Shared types, contracts, extension messages
  sdk/                — Public SDK (@getvouch/sdk)
  web-proof-sdk/      — Internal web proof SDK
  extension-api-hooks/— React hooks for extension
  wasm/, outputs_wasm/— WASM bindings
  rust/               — 15 Rust crates (prover, redaction, request_matcher, etc.)
```



[...truncated]

**Actions:**
- Read `/home/michal/dev/work/vlayer/vouch/README.md`
- Bash: `ls /home/michal/dev/work/vlayer/vouch/`
- Bash: `ls /home/michal/dev/work/vlayer/vouch/apps/ 2>/dev/null; echo "---"; ls /home/michal/dev/work/vlayer`
- Bash: `test -d /home/michal/dev/work/vlayer/vouch/.beads && echo "beads found" || echo "no beads"`
- Read `/home/michal/dev/work/vlayer/vouch/package.json`
- Bash: `ls /home/michal/dev/work/vlayer/vouch/packages/rust/`

---

### User

see the @apps/vouch/domain/proof-request/verification/index.ts ; describe how the verifyWebProof works, in particular focus on how we use tlsn-wasm-latest for verification in this file and how it is used in the whole project; generate comprehensive md summary at @apps/vouch/domain/proof-request/verification/VERIFICATION_SUMMARY.md

---

### Claude

Let me read the referenced file and trace the usage through the project.

Now let me look at how the service calls this and how the WebProof type is structured.

Now I have everything I need. Let me write the summary.

Written to `apps/vouch/domain/proof-request/verification/VERIFICATION_SUMMARY.md`.

**Quick summary of how it works:**

The server receives a `WebProof` containing hex-encoded TLSN proof data + a plaintext decoded transcript. `verifyWebProof()` routes by version (alpha.11 vs alpha.12), then initializes the `tlsn-wasm` WASM module in Node.js (with browser API polyfills) and runs `Presentation.deserialize(proof).verify()` — this is the core cryptographic check that validates the notary's signatures, TLS certificate chain, and transcript integrity.

The output is a `VerifiedWebProof` with the server hostname and a `PartialTranscript` (byte arrays with authenticated ranges). The caller (`ProofRequestService`) then uses this to match URL patterns, extract outputs from the authenticated HTTP response body, and detect resubmissions.

There's a narrow fallback for 4 Access Bank data sources where cert verification fails due to missing intermediate certificates — in that case

[...truncated]

**Actions:**
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/verification/index.ts`
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/verification/cert-fallback.ts`
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/verification/legacy-verifications.ts`
- Grep: `from "tlsn-wasm-latest"`
- Glob: `apps/vouch/domain/proof-request/verification/*`
- Grep: `verifyWebProof`
- Grep: `from "tlsn-wasm`
- Grep: `tlsn-wasm-latest`
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/lib/tlsn-wasm/polyfill.ts`
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/verification/legacy-verifications/index.ts`
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/verification/legacy-verifications/tlsn-alpha11.ts`
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/service.ts`
- Read `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/verification/verification.test.ts`
- Grep: `interface WebProof|type WebProof`
- Grep: `Presentation|initSync`
- Read `/home/michal/dev/work/vlayer/vouch/packages/common/contracts/web-proof.ts`
- Write `/home/michal/dev/work/vlayer/vouch/apps/vouch/domain/proof-request/verification/VERIFICATION_SUMMARY.md`

---

