# Firestore Security Rules tests

These tests run only against the local Firebase Firestore Emulator. The test
script uses the `demo-cardioguard-rules` project ID, so Firebase Tools refuses
to fall back to non-emulated production services.

## Prerequisites

- Node.js
- Java 21 or newer

## Install dependencies

From the project root:

```powershell
npm.cmd ci
```

`npm.cmd` is used on Windows to avoid PowerShell execution-policy problems
with `npm.ps1`.

## Run the tests

```powershell
npm.cmd run test:rules
```

Firebase Tools starts the Firestore Emulator, loads the root
`firestore.rules`, runs all tests in `tests/firestore.rules.test.js`, and then
stops the emulator. Firebase login is not required for this demo project.

Test fixtures are inserted with `withSecurityRulesDisabled()` inside the local
emulator only. Each test clears and reseeds emulator data, and no production
Firebase data is read or modified.
