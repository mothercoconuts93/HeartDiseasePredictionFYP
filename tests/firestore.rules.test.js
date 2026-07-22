// Emulator-only authorization tests for CardioGuard's Firestore rules.

const fs = require('node:fs');
const path = require('node:path');
const { after, before, beforeEach, test } = require('node:test');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');

const PROJECT_ID = 'demo-cardioguard-rules';
const PATIENT_UID = 'patient-alice';
const OTHER_PATIENT_UID = 'patient-bob';
const PRACTITIONER_UID = 'practitioner-claire';

let testEnv;

function profile(uid, role, fullName) {
  // Build the minimum user shape needed by the security-rule scenarios.
  return {
    uid,
    fullName,
    email: `${uid}@cardioguard.test`,
    role,
    createdAt: '2026-07-15T00:00:00.000Z',
  };
}

function prediction(userId, predictionId) {
  // Build an isolated prediction fixture without calling the live API.
  return {
    predictionId,
    userId,
    riskLevel: 'Moderate Risk',
    probability: 0.65,
    createdAt: '2026-07-15T00:00:00.000Z',
  };
}

function authenticatedFirestore(uid, tokenOptions = {}) {
  return testEnv.authenticatedContext(uid, tokenOptions).firestore();
}

async function seedFirestore() {
  // Seed local fixtures with rules disabled; production data is never touched.
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await Promise.all([
      setDoc(
        doc(db, 'users', PATIENT_UID),
        profile(PATIENT_UID, 'Patient', 'Alice Patient'),
      ),
      setDoc(
        doc(db, 'users', OTHER_PATIENT_UID),
        profile(OTHER_PATIENT_UID, 'Patient', 'Bob Patient'),
      ),
      setDoc(
        doc(db, 'users', PRACTITIONER_UID),
        profile(PRACTITIONER_UID, 'Practitioner', 'Dr Claire Practitioner'),
      ),
      setDoc(
        doc(db, 'predictions', 'alice-prediction'),
        prediction(PATIENT_UID, 'alice-prediction'),
      ),
      setDoc(
        doc(db, 'predictions', 'bob-prediction'),
        prediction(OTHER_PATIENT_UID, 'bob-prediction'),
      ),
    ]);
  });
}

before(async () => {
  const rules = fs.readFileSync(
    path.resolve(__dirname, '..', 'firestore.rules'),
    'utf8',
  );

  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seedFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

test('unauthenticated user reads users - denied', async () => {
  const db = testEnv.unauthenticatedContext().firestore();

  await assertFails(getDocs(collection(db, 'users')));
});

test('patient reads own profile - allowed', async () => {
  const db = authenticatedFirestore(PATIENT_UID);

  await assertSucceeds(getDoc(doc(db, 'users', PATIENT_UID)));
});

test("patient reads another patient's profile - denied", async () => {
  const db = authenticatedFirestore(PATIENT_UID);

  await assertFails(getDoc(doc(db, 'users', OTHER_PATIENT_UID)));
});

test('patient creates their own profile with role Patient - allowed', async () => {
  const uid = 'new-patient';
  const db = authenticatedFirestore(uid);

  await assertSucceeds(
    setDoc(doc(db, 'users', uid), profile(uid, 'Patient', 'New Patient')),
  );
});

test('patient creates their profile with role Practitioner - denied', async () => {
  const uid = 'malicious-new-user';
  const db = authenticatedFirestore(uid);

  await assertFails(
    setDoc(
      doc(db, 'users', uid),
      profile(uid, 'Practitioner', 'Not A Practitioner'),
    ),
  );
});

test('patient updates their role from Patient to Practitioner - denied', async () => {
  const db = authenticatedFirestore(PATIENT_UID);

  await assertFails(
    updateDoc(doc(db, 'users', PATIENT_UID), { role: 'Practitioner' }),
  );
});

test('patient reads own predictions - allowed', async () => {
  const db = authenticatedFirestore(PATIENT_UID);

  await assertSucceeds(
    getDocs(
      query(
        collection(db, 'predictions'),
        where('userId', '==', PATIENT_UID),
      ),
    ),
  );
});

test("patient reads another patient's prediction - denied", async () => {
  const db = authenticatedFirestore(PATIENT_UID);

  await assertFails(getDoc(doc(db, 'predictions', 'bob-prediction')));
});

test('patient creates a prediction using own UID - allowed', async () => {
  const db = authenticatedFirestore(PATIENT_UID);

  await assertSucceeds(
    setDoc(
      doc(db, 'predictions', 'alice-new-prediction'),
      prediction(PATIENT_UID, 'alice-new-prediction'),
    ),
  );
});

test('patient creates a prediction using another UID - denied', async () => {
  const db = authenticatedFirestore(PATIENT_UID);

  await assertFails(
    setDoc(
      doc(db, 'predictions', 'forged-prediction'),
      prediction(OTHER_PATIENT_UID, 'forged-prediction'),
    ),
  );
});

test('verified Practitioner reads Patient profiles - allowed', async () => {
  const db = authenticatedFirestore(PRACTITIONER_UID, {
    email: 'practitioner-claire@cardioguard.test',
    email_verified: true,
  });

  await assertSucceeds(
    getDocs(
      query(collection(db, 'users'), where('role', '==', 'Patient')),
    ),
  );
});

test('verified Practitioner reads Patient predictions - allowed', async () => {
  const db = authenticatedFirestore(PRACTITIONER_UID, {
    email: 'practitioner-claire@cardioguard.test',
    email_verified: true,
  });

  await assertSucceeds(
    getDocs(collection(db, 'predictions')),
  );
});
