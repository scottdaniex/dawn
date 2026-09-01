# Dispatch Assignment: e2e_test_writer_1

## Task
You are the E2E Test Suite Architect.
Your working directory: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\e2e_test_writer_1`.
Read:
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\ORIGINAL_REQUEST.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\PROJECT.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\survey_spec_miner_1\report.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\survey_explorer_2\report.md`

Your mission:
1. Create `TEST_INFRA.md` at `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\TEST_INFRA.md` following the template in PROJECT.md.
2. Build an opaque-box automated test suite (e.g. `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\tests\run_e2e_tests.ps1` and test scripts) covering all 4 Tiers:
   - Tier 1: Feature Coverage (≥5 tests per feature for R1, R2, R3, R4)
   - Tier 2: Boundary & Corner Cases (≥5 tests per feature)
   - Tier 3: Cross-Feature Combinations (Pairwise interaction tests)
   - Tier 4: Real-World Application Scenarios (Realistic desk gear shopper flows)
   - Include strict Liquid tag validation, schema JSON validation, template integrity, CSS token verification, cart drawer meter logic, and sticky ATC verification.
3. Once the test suite is implemented, verify that it runs cleanly via PowerShell and publish `TEST_READY.md` at `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\TEST_READY.md`.
4. Deliver report in `report.md` and complete with `handoff.md`.
