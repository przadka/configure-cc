---
name: review-pr
description: Review a pull request using parallel agents for thorough coverage
disable-model-invocation: true
argument-hint: "[PR number or URL]"
---

Review pull request $ARGUMENTS using parallel review agents.

1. Fetch the PR diff: `gh pr diff $ARGUMENTS`
2. Spawn 3 parallel review agents:
   - **Correctness**: logic bugs, edge cases, error handling gaps
   - **Security**: injection risks, auth issues, data exposure
   - **Style**: naming, consistency with existing patterns, unnecessary complexity
3. Collect findings into a single triaged list:
   - **P1** (must fix): bugs, security issues, data loss risks
   - **P2** (should fix): logic gaps, missing validation, poor error messages
   - **P3** (nitpick): style, naming, minor improvements
4. Present the consolidated list and ask which issues to address
5. When posting to GitHub, use `CHANGES_REQUESTED` (not `COMMENT`) if P1/P2 issues exist
6. Always create secret gists (never public) for shared artifacts
