# CardioGuard Use Case Specifications

These specifications describe only behaviour implemented in the connected
CardioGuard repository. Paths are relative to the repository root.

## UC-01 Register Account

- **Use Case ID:** UC-01
- **Use Case Name:** Register Account
- **Primary Actor:** Patient
- **Supporting Actor or System:** Firebase Authentication; Cloud Firestore
- **Goal:** Create a public CardioGuard patient account and matching profile.
- **Preconditions:** The person is signed out and has opened the Registration screen.
- **Trigger:** The patient selects `Register` after entering the required account details.
- **Main Success Scenario:**
  1. The patient enters full name, email, password, and password confirmation.
  2. Flutter confirms that every field is populated and both passwords match.
  3. Firebase Authentication creates the account.
  4. CardioGuard obtains the new Firebase UID.
  5. CardioGuard writes `users/{uid}` with the same `uid`, the entered identity data, `role: Patient`, and `createdAt`.
  6. The current user profile is loaded.
  7. The Patient Dashboard opens.
- **Alternative and Exception Flows:**
  - Missing fields display `Please fill in all fields.` and no account is created.
  - Different passwords display `Passwords do not match.` and no account is created.
  - Firebase Authentication or Firestore failure leaves the user on Registration and displays the provider error.
  - The client and Firestore rules reject public creation of a Practitioner profile.
- **Postconditions:** A Firebase account and corresponding Patient profile exist, and the patient is authenticated.
- **Implementation Evidence:** `flutter_app/lib/screens/auth/register_screen.dart` — `_RegisterScreenState.registerUser()`; `flutter_app/lib/providers/auth_provider.dart` — `AuthProvider.register()`; `flutter_app/lib/services/auth_service.dart` — `AuthService.registerUser()`; `firestore.rules` — `match /users/{userId}` create rule.
- **Related Functional Requirement:** **FR-01:** The system shall allow a public user to register an account whose application role is Patient.

## UC-02 Login

- **Use Case ID:** UC-02
- **Use Case Name:** Login
- **Primary Actor:** Patient or Practitioner
- **Supporting Actor or System:** Firebase Authentication; Cloud Firestore
- **Goal:** Authenticate and open the dashboard authorised by the Firestore role.
- **Preconditions:** A Firebase account and matching `users/{uid}` profile exist.
- **Trigger:** The actor selects `Login to Account`.
- **Main Success Scenario:**
  1. Flutter submits the trimmed email and password to Firebase Authentication.
  2. Firebase returns the authenticated user and UID.
  3. CardioGuard reads `users/{uid}` from Firestore.
  4. `UserModel.fromMap()` validates that the role is `Patient` or `Practitioner`.
  5. A Patient is routed to the Patient Dashboard.
  6. A Practitioner is routed to the Practitioner Dashboard.
- **Alternative and Exception Flows:**
  - Invalid credentials or Firebase failure returns an error and leaves Login open.
  - A missing profile, invalid role, or profile-read failure prevents dashboard navigation.
  - If authentication succeeded before profile loading failed, the provider attempts to sign the user out.
  - During application launch, `AuthGate` shows a loading state while authentication and profile state are resolved.
- **Postconditions:** The actor is authenticated and the correct role dashboard is displayed.
- **Implementation Evidence:** `flutter_app/lib/screens/auth/login_screen.dart` — `_LoginScreenState.loginUser()`; `flutter_app/lib/providers/auth_provider.dart` — `AuthProvider.login()` and `loadCurrentUserData()`; `flutter_app/lib/services/auth_service.dart` — `loginUser()` and `getCurrentUserData()`; `flutter_app/lib/models/user_model.dart` — `UserModel.fromMap()`; `flutter_app/lib/main.dart` — `AuthGate`.
- **Related Functional Requirement:** **FR-02:** The system shall authenticate registered users and route them according to the validated Firestore role.

## UC-03 Reset Password

- **Use Case ID:** UC-03
- **Use Case Name:** Reset Password
- **Primary Actor:** Patient or Practitioner
- **Supporting Actor or System:** Firebase Authentication
- **Goal:** Request a Firebase password-reset email.
- **Preconditions:** The actor is on Login and can open Forgot Password.
- **Trigger:** The actor enters an email and selects `Send Reset Link`.
- **Main Success Scenario:**
  1. Flutter submits the trimmed email to Firebase Authentication.
  2. Firebase accepts the reset request.
  3. CardioGuard displays the neutral reset-link confirmation.
  4. The Forgot Password screen returns to Login.
- **Alternative and Exception Flows:**
  - Firebase rejection or connectivity failure displays the provider error and keeps the screen open.
  - No separate local empty-email validator is implemented; Firebase handles invalid input.
- **Postconditions:** A reset request has been accepted by Firebase; the password is not changed inside CardioGuard.
- **Implementation Evidence:** `flutter_app/lib/screens/auth/forgot_password_screen.dart` — `_ForgotPasswordScreenState.resetPassword()`; `flutter_app/lib/providers/auth_provider.dart` — `AuthProvider.resetPassword()`; `flutter_app/lib/services/auth_service.dart` — `AuthService.resetPassword()`.
- **Related Functional Requirement:** **FR-03:** The system shall allow a user to request password recovery through Firebase Authentication.

## UC-04 Log Out

- **Use Case ID:** UC-04
- **Use Case Name:** Log Out
- **Primary Actor:** Patient or Practitioner
- **Supporting Actor or System:** Firebase Authentication
- **Goal:** End the authenticated session and return to Login.
- **Preconditions:** The actor is authenticated and viewing the role profile screen.
- **Trigger:** The actor selects `Logout` and confirms the dialog.
- **Main Success Scenario:**
  1. CardioGuard asks the actor to confirm logout.
  2. The actor confirms.
  3. Firebase Authentication signs the actor out.
  4. `AuthProvider.currentUserData` is cleared.
  5. CardioGuard clears the navigation stack and opens Login.
- **Alternative and Exception Flows:**
  - Selecting `Cancel` closes the dialog without changing the session.
- **Postconditions:** The Firebase session and in-memory profile are cleared.
- **Implementation Evidence:** `flutter_app/lib/screens/patient/profile_screen.dart` — `ProfileScreen.logout()`; `flutter_app/lib/screens/practitioner/practitioner_profile_screen.dart` — `PractitionerProfileScreen._logout()`; `flutter_app/lib/providers/auth_provider.dart` — `AuthProvider.logout()`; `flutter_app/lib/services/auth_service.dart` — `AuthService.logoutUser()`.
- **Related Functional Requirement:** **FR-04:** The system shall allow an authenticated user to terminate the session securely.

## UC-05 View Profile

- **Use Case ID:** UC-05
- **Use Case Name:** View Profile
- **Primary Actor:** Patient or Practitioner
- **Supporting Actor or System:** Cloud Firestore; Firebase Authentication
- **Goal:** Review the identity and role information associated with the current account.
- **Preconditions:** The actor is authenticated and the Firestore profile has been loaded.
- **Trigger:** The actor selects `Profile`.
- **Main Success Scenario:**
  1. CardioGuard reads the profile already held by `AuthProvider`.
  2. A Patient sees name, email, role, and joined date.
  3. A Practitioner sees name, email, role, and member-since date.
  4. The screen provides policy links and logout access appropriate to the role.
- **Alternative and Exception Flows:**
  - Fallback labels are displayed if profile display data is unavailable.
  - No profile-editing controls are presented.
- **Postconditions:** No persistent data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/patient/profile_screen.dart` — `ProfileScreen.build()`; `flutter_app/lib/screens/practitioner/practitioner_profile_screen.dart` — `PractitionerProfileScreen.build()`; `flutter_app/lib/providers/auth_provider.dart` — `currentUserData`.
- **Related Functional Requirement:** **FR-05:** The system shall display the authenticated user’s stored account and role information.

## UC-06 Complete Health Assessment

- **Use Case ID:** UC-06
- **Use Case Name:** Complete Health Assessment
- **Primary Actor:** Patient
- **Supporting Actor or System:** Firebase Authentication; FastAPI Prediction API through UC-07
- **Goal:** Supply the 15 required health and lifestyle values for prediction.
- **Preconditions:** The patient is authenticated and has opened `Cardiovascular Assessment`.
- **Trigger:** The patient enters assessment values and selects `Run Prediction`.
- **Main Success Scenario:**
  1. CardioGuard checks that a Firebase user is authenticated.
  2. The patient enters the seven numeric and eight categorical values.
  3. Flutter validates required numeric input, integer format, and configured ranges.
  4. Flutter constructs `HealthAssessmentModel` using the selected descriptive categorical strings.
  5. The workflow includes UC-07 Generate Heart Disease Prediction.
- **Alternative and Exception Flows:**
  - An unauthenticated user receives `You must be logged in to run a prediction.`
  - Invalid input is highlighted and the patient receives `Review the highlighted assessment fields.`
  - The patient remains on the form until validation succeeds or leaves the screen.
- **Postconditions:** On validation success, a transient `HealthAssessmentModel` is submitted. Raw assessment values are not stored in Firestore.
- **Implementation Evidence:** `flutter_app/lib/screens/patient/prediction_screen.dart` — `_validateNumber()`, `_numberField()`, `submitPrediction()`; `flutter_app/lib/models/health_assessment_model.dart` — `HealthAssessmentModel` and `toJson()`.
- **Related Functional Requirement:** **FR-06:** The system shall collect and validate the exact 15 production model inputs from an authenticated patient.

## UC-07 Generate Heart Disease Prediction

- **Use Case ID:** UC-07
- **Use Case Name:** Generate Heart Disease Prediction
- **Primary Actor:** Patient
- **Supporting Actor or System:** FastAPI Prediction API; Random Forest Pipeline v2; Cloud Firestore
- **Goal:** Generate, classify, and persist a heart-disease risk prediction from a valid assessment.
- **Preconditions:** UC-06 has produced a valid `HealthAssessmentModel`, the v2 API is reachable, and the v2 pipeline is loaded.
- **Trigger:** `PredictionProvider.runPrediction()` receives the authenticated UID and valid assessment.
- **Main Success Scenario:**
  1. `PredictionService` serialises the assessment and sends `POST /predict/v2`.
  2. FastAPI validates `PatientDataV2`.
  3. FastAPI creates a one-row DataFrame in the exact 15-column production order.
  4. `heart_pipeline_v2.pkl` imputes missing values, encodes categorical data, and executes the Random Forest classifier.
  5. FastAPI obtains the predicted class and positive-class probability.
  6. FastAPI converts probability to a percentage and classifies the risk.
  7. FastAPI returns prediction, risk level, probability, recommendation, model, and status.
  8. Flutter generates a UUID and constructs `PredictionModel`.
  9. Flutter writes `predictions/{UUID}` to Firestore.
  10. The provider reports success only after the Firestore write completes.
- **Alternative and Exception Flows:**
  - Invalid v2 input returns HTTP 422 and Flutter displays a validation-oriented service error.
  - Network timeout, HTTP failure, unreadable response, or unexpected response shape produces a user-facing error.
  - Pipeline unavailability returns HTTP 503.
  - Inference failure returns a sanitised HTTP 500 response.
  - Firestore write failure makes the overall operation fail even if inference succeeded.
- **Postconditions:** On success, an immutable prediction document exists for the authenticated patient. The raw assessment is not persisted.
- **Implementation Evidence:** `flutter_app/lib/providers/prediction_provider.dart` — `PredictionProvider.runPrediction()`; `flutter_app/lib/services/prediction_service.dart` — `predictHeartDisease()`; `backend/main.py` — `PatientDataV2`, `FEATURE_COLUMNS`, `predict_v2()`, and `classify_risk()`; `machine_learning/train_pipeline_v2.py` — `build_pipeline()`; `flutter_app/lib/services/firestore_service.dart` — `savePrediction()`; `firestore.rules` — prediction create rule.
- **Related Functional Requirement:** **FR-07:** The system shall use the versioned FastAPI/Random Forest pipeline to generate and save a risk prediction for a valid patient assessment.

## UC-08 View Prediction Result

- **Use Case ID:** UC-08
- **Use Case Name:** View Prediction Result
- **Primary Actor:** Patient
- **Supporting Actor or System:** None during display; data originates from UC-07
- **Goal:** Review the generated risk level, probability, and recommendation.
- **Preconditions:** UC-07 completed successfully, including the Firestore save.
- **Trigger:** `PredictionScreen` receives success and opens `ResultScreen`.
- **Main Success Scenario:**
  1. CardioGuard displays `Analysis Complete`.
  2. The patient sees the risk badge and risk-level text.
  3. The patient sees the percentage and LOW–MODERATE–HIGH indicator.
  4. The patient sees the generated medical recommendation and disclaimer.
  5. The patient can return through the available navigation.
- **Alternative and Exception Flows:**
  - Selecting `Result Saved to History` only confirms that the preceding save already occurred.
  - The screen is not opened if API inference or Firestore persistence fails.
- **Postconditions:** No additional data change occurs.
- **Implementation Evidence:** `flutter_app/lib/screens/patient/result_screen.dart` — `ResultScreen`; `flutter_app/lib/screens/patient/prediction_screen.dart` — success navigation in `submitPrediction()`.
- **Related Functional Requirement:** **FR-08:** The system shall display the successfully saved prediction’s risk, probability, and recommendation.

## UC-09 View Health Recommendations

- **Use Case ID:** UC-09
- **Use Case Name:** View Health Recommendations
- **Primary Actor:** Patient
- **Supporting Actor or System:** None
- **Goal:** Read preventive heart-health guidance.
- **Preconditions:** The Patient Dashboard is available.
- **Trigger:** The patient selects `Health Recommendations`.
- **Main Success Scenario:**
  1. CardioGuard opens the recommendations screen.
  2. The patient reads the five implemented recommendation cards.
  3. The patient returns using normal back navigation.
- **Alternative and Exception Flows:** No data-loading or mutation alternatives exist because the content is static.
- **Postconditions:** No system data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/patient/patient_home_screen.dart` — Health Recommendations navigation; `flutter_app/lib/screens/patient/health_recommendations_screen.dart` — `HealthRecommendationsScreen`.
- **Related Functional Requirement:** **FR-09:** The system shall provide patients with the implemented static preventive heart-health guidance.

## UC-10 View Prediction History

- **Use Case ID:** UC-10
- **Use Case Name:** View Prediction History
- **Primary Actor:** Patient
- **Supporting Actor or System:** Firebase Authentication; Cloud Firestore
- **Goal:** Review the authenticated patient’s previous saved prediction results.
- **Preconditions:** The patient is authenticated.
- **Trigger:** The patient selects `Prediction History` or bottom navigation `History`.
- **Main Success Scenario:**
  1. CardioGuard obtains the current Firebase UID.
  2. Firestore is queried for predictions where `userId` equals that UID.
  3. Results are sorted newest first in Flutter.
  4. The first ten prediction cards are displayed.
  5. The patient may load additional groups of ten.
- **Alternative and Exception Flows:**
  - An unauthenticated state displays the login requirement.
  - A pending stream displays a loading indicator.
  - A query error displays the implemented history error.
  - No records displays `No prediction history found.`
- **Postconditions:** No persistent data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/patient/history_screen.dart` — `HistoryScreen`; `flutter_app/lib/providers/prediction_provider.dart` — `getPredictionHistory()`; `flutter_app/lib/services/firestore_service.dart` — `getPredictionsByUser()`; `firestore.rules` — prediction read rule.
- **Related Functional Requirement:** **FR-10:** The system shall allow a patient to retrieve only their own saved prediction history.

## UC-11 View Prediction Details

- **Use Case ID:** UC-11
- **Use Case Name:** View Prediction Details
- **Primary Actor:** Patient
- **Supporting Actor or System:** None during display
- **Goal:** Inspect one selected historical prediction.
- **Preconditions:** The patient is viewing a non-empty Prediction History.
- **Trigger:** The patient selects a prediction card.
- **Main Success Scenario:**
  1. CardioGuard passes the selected `PredictionModel` to `PredictionDetailScreen`.
  2. The screen displays date/time, risk, probability, scale, and recommendation.
  3. The screen displays the medical disclaimer and prediction reference.
- **Alternative and Exception Flows:** No separate query is performed; navigation is unavailable when no history record exists.
- **Postconditions:** No persistent data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/patient/history_screen.dart` — record `onTap`; `flutter_app/lib/screens/patient/prediction_detail_screen.dart` — `PredictionDetailScreen`.
- **Related Functional Requirement:** **FR-11:** The system shall display the details of a prediction selected from the patient’s history.

## UC-12 View Privacy Policy and Terms

- **Use Case ID:** UC-12
- **Use Case Name:** View Privacy Policy and Terms
- **Primary Actor:** Patient or Practitioner
- **Supporting Actor or System:** None
- **Goal:** Read the implemented privacy and usage information.
- **Preconditions:** The actor is on Login, Patient Settings, or Practitioner Profile.
- **Trigger:** The actor selects `Privacy Policy` or `Terms of Service`.
- **Main Success Scenario:**
  1. CardioGuard opens the selected static document screen.
  2. The actor reads the implemented sections.
  3. The actor returns using back navigation.
- **Alternative and Exception Flows:** These screens do not load remote content and have no data mutation flow.
- **Postconditions:** No system data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/profile/privacy_policy_screen.dart` — `PrivacyPolicyScreen`; `flutter_app/lib/screens/profile/terms_screen.dart` — `TermsScreen`; navigation in `flutter_app/lib/screens/auth/login_screen.dart`, `flutter_app/lib/screens/profile/settings_screen.dart`, and `flutter_app/lib/screens/practitioner/practitioner_profile_screen.dart`.
- **Related Functional Requirement:** **FR-12:** The system shall make its implemented privacy policy and terms available from the relevant authentication and profile interfaces.

## UC-13 View Practitioner Dashboard

- **Use Case ID:** UC-13
- **Use Case Name:** View Practitioner Dashboard
- **Primary Actor:** Practitioner
- **Supporting Actor or System:** Cloud Firestore
- **Goal:** Review current patient and latest-risk summary statistics.
- **Preconditions:** The actor is authenticated with a Firestore role of `Practitioner`.
- **Trigger:** Role-based routing or practitioner Home navigation opens the dashboard.
- **Main Success Scenario:**
  1. CardioGuard queries user profiles whose role is `Patient`.
  2. CardioGuard queries all predictions in descending creation order.
  3. Flutter identifies the first/latest prediction for each patient.
  4. Flutter calculates total patients, high-risk patients, and average latest-risk score.
  5. The dashboard displays the calculated values.
- **Alternative and Exception Flows:**
  - Patient-stream loading displays a progress indicator.
  - Patient-stream failure displays `Unable to load patient dashboard.`
  - The current implementation has no explicit prediction-stream error state; absent prediction data produces zero/empty-derived metrics.
- **Postconditions:** Dashboard values are calculated in memory and are not stored.
- **Implementation Evidence:** `flutter_app/lib/screens/practitioner/practitioner_home_screen.dart` — `PractitionerHomeScreen`; `flutter_app/lib/services/firestore_service.dart` — `getPatients()` and `getAllPredictions()`; `firestore.rules` — practitioner read permissions.
- **Related Functional Requirement:** **FR-13:** The system shall present practitioners with dynamically calculated patient and risk summary statistics.

## UC-14 View Patient List

- **Use Case ID:** UC-14
- **Use Case Name:** View Patient List
- **Primary Actor:** Practitioner
- **Supporting Actor or System:** Cloud Firestore
- **Goal:** Locate and review registered patients and their latest risk summary.
- **Preconditions:** The actor is authenticated as a Practitioner.
- **Trigger:** The practitioner selects `Patient List — Search & Manage Records`.
- **Main Success Scenario:**
  1. CardioGuard queries all `Patient` user profiles and all predictions.
  2. Flutter associates each patient with the latest matching prediction.
  3. The directory displays patient cards.
  4. The practitioner may search by name/email, filter by risk, sort, and load more records.
  5. The practitioner selects a patient.
- **Alternative and Exception Flows:**
  - Loading displays a progress indicator.
  - Patient or prediction-stream errors display the implemented error message.
  - No patients or no filter matches display the corresponding empty state.
- **Postconditions:** No profile or prediction is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/practitioner/patient_list_screen.dart` — `PatientListScreen` and `_visibleRecords()`; `flutter_app/lib/services/firestore_service.dart` — `getPatients()` and `getAllPredictions()`.
- **Related Functional Requirement:** **FR-14:** The system shall allow a practitioner to view and locate Patient profiles with their latest available risk information.

## UC-15 View Patient Details

- **Use Case ID:** UC-15
- **Use Case Name:** View Patient Details
- **Primary Actor:** Practitioner
- **Supporting Actor or System:** None during display
- **Goal:** Review a selected patient’s identity and one latest or selected prediction.
- **Preconditions:** A patient has been selected from Patient List, or an assessment with a matching patient has been selected from Assessment History.
- **Trigger:** The practitioner selects the patient or assessment record.
- **Main Success Scenario:**
  1. CardioGuard passes `UserModel` and an optional `PredictionModel` to `PatientDetailScreen`.
  2. The screen displays patient name and email.
  3. If supplied, the screen displays risk, assessment date, probability, and recommendation.
- **Alternative and Exception Flows:**
  - A patient without a prediction displays `No prediction yet`, `No assessment yet`, `N/A`, and the implemented fallback recommendation.
  - No per-patient history query or edit action is available.
- **Postconditions:** No data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/practitioner/patient_detail_screen.dart` — `PatientDetailScreen`; navigation from `flutter_app/lib/screens/practitioner/patient_list_screen.dart` and `flutter_app/lib/screens/practitioner/practitioner_history_screen.dart`.
- **Related Functional Requirement:** **FR-15:** The system shall allow a practitioner to view a selected Patient profile and the prediction supplied by the originating workflow.

## UC-16 View Assessment History

- **Use Case ID:** UC-16
- **Use Case Name:** View Assessment History
- **Primary Actor:** Practitioner
- **Supporting Actor or System:** Cloud Firestore
- **Goal:** Review the global collection of patient prediction records.
- **Preconditions:** The actor is authenticated as a Practitioner.
- **Trigger:** The practitioner selects bottom navigation `History`.
- **Main Success Scenario:**
  1. CardioGuard queries all Patient profiles.
  2. CardioGuard queries all predictions ordered by `createdAt` descending.
  3. Flutter associates each prediction with a patient using `Prediction.userId`.
  4. The screen displays patient name, risk, date/time, and probability for each record.
  5. The practitioner may select an assessment that has a matching patient.
- **Alternative and Exception Flows:**
  - Patient or prediction loading displays a progress indicator.
  - Stream failures display the corresponding implemented error.
  - No records displays `No patient assessments found.`
  - A prediction with no matching patient displays `Unknown patient` and cannot be opened.
- **Postconditions:** No persistent data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/practitioner/practitioner_history_screen.dart` — `PractitionerHistoryScreen`; `flutter_app/lib/services/firestore_service.dart` — `getPatients()` and `getAllPredictions()`; `firestore.rules` — practitioner prediction-read permission.
- **Related Functional Requirement:** **FR-16:** The system shall allow a practitioner to view all available patient assessment results in descending creation order.

## UC-17 View Selected Assessment

- **Use Case ID:** UC-17
- **Use Case Name:** View Selected Assessment
- **Primary Actor:** Practitioner
- **Supporting Actor or System:** None during display
- **Goal:** Inspect the patient and result associated with a record selected from Assessment History.
- **Preconditions:** Assessment History contains a prediction whose `userId` matches a loaded Patient profile.
- **Trigger:** The practitioner selects that assessment record.
- **Main Success Scenario:**
  1. CardioGuard finds the matching patient by `prediction.userId`.
  2. The selected patient and prediction are passed to `PatientDetailScreen`.
  3. The practitioner reviews identity, risk, assessment date, probability, and recommendation.
- **Alternative and Exception Flows:**
  - If no matching patient exists, the assessment remains visible as `Unknown patient` but selection is disabled.
  - The destination does not display the selected patient’s complete history.
- **Postconditions:** No persistent data is changed.
- **Implementation Evidence:** `flutter_app/lib/screens/practitioner/practitioner_history_screen.dart` — prediction-to-patient map and record `onTap`; `flutter_app/lib/screens/practitioner/patient_detail_screen.dart` — `PatientDetailScreen`.
- **Related Functional Requirement:** **FR-17:** The system shall allow a practitioner to inspect a selectable assessment record together with its matched Patient profile.
