# CardioGuard UML Design Documentation

This directory contains the final implementation-aligned design diagrams for
CardioGuard. The diagrams describe the repository as implemented; they do not
add planned or inferred functionality.

## Contents

| File | Purpose |
|---|---|
| `use_case_diagram.mmd` | Patient, Practitioner, supporting systems, and verified user goals inside the CardioGuard system boundary |
| `use_case_specifications.md` | Detailed UC-01 to UC-17 specifications and implementation traceability |
| `activity_diagram.mmd` | Swimlane-style patient health-assessment and prediction workflow |
| `sequence_diagram.mmd` | Runtime interaction from assessment submission through FastAPI inference and Flutter-managed Firestore persistence |
| `er_diagram.mmd` | Conceptual Firestore `USER` and `PREDICTION` entities and their logical one-to-many relationship |

## Repository evidence used

The diagrams were derived from:

- Flutter entry and role routing:
  `flutter_app/lib/main.dart`
- Flutter screens:
  `flutter_app/lib/screens/auth/`,
  `flutter_app/lib/screens/patient/`,
  `flutter_app/lib/screens/practitioner/`, and
  `flutter_app/lib/screens/profile/`
- Flutter models:
  `flutter_app/lib/models/user_model.dart`,
  `prediction_model.dart`, and `health_assessment_model.dart`
- Flutter state and integration layers:
  `flutter_app/lib/providers/auth_provider.dart`,
  `prediction_provider.dart`,
  `flutter_app/lib/services/auth_service.dart`,
  `firestore_service.dart`, and `prediction_service.dart`
- FastAPI contracts and endpoints:
  `backend/main.py`
- Production v2 pipeline construction:
  `machine_learning/train_pipeline_v2.py`
- Firestore authorization:
  `firestore.rules`
- Behavioural evidence:
  `backend/test_main.py`,
  `flutter_app/test/`, and
  `tests/firestore.rules.test.js`

## Modelling decisions

### Use-case notation

Mermaid does not provide native UML use-case syntax. The use-case diagram uses
a Mermaid flowchart with:

- labelled actor nodes;
- stadium-shaped use-case nodes;
- a subgraph as the CardioGuard system boundary;
- dashed, labelled dependencies for `«include»` and `«extend»`.

The diagram uses `Reset Password «extend» Login` and
`Complete Health Assessment «include» Generate Heart Disease Prediction` as
required. Other associations do not use include/extend to imply screen order.

### Authentication and roles

Patient and Practitioner are the only human actors. Both roles use Firebase
Authentication, and the dashboard decision is based on the exact Firestore
role loaded from `users/{uid}`. Public registration creates Patients only.

### Prediction ownership

The active mobile workflow calls `POST /predict/v2` and
`heart_pipeline_v2.pkl`. FastAPI returns inference output, but Flutter creates
the prediction UUID and saves `predictions/{UUID}` through
`FirestoreService`. No Firebase token is sent to FastAPI, and FastAPI does not
write to Firestore.

### Persistence

The conceptual ER model contains only the two top-level Firestore collections
used by the application:

- `users/{uid}`
- `predictions/{predictionId}`

`PREDICTION.userId` is a logical reference to `USER.uid`; Firestore does not
enforce a traditional foreign key. A user can have zero or many predictions,
and each normal prediction belongs logically to one user.

Current Flutter writers serialise `createdAt` as an ISO-8601 string. Model
parsers also accept Firestore `Timestamp` values, so the ER diagram represents
`createdAt` as a logical date/time rather than claiming one physical Firestore
type for every existing document.

## Excluded features and reasons

| Excluded item | Reason |
|---|---|
| Practitioner Registration | No public practitioner-registration workflow exists |
| Update or Manage Profile | Profile screens display data but provide no editing interface |
| Edit/Delete Patient | No implementation exists |
| Edit/Delete Prediction | No interface exists and Firestore rules deny both operations |
| Notifications | Disabled setting labelled coming soon |
| Dark Mode | Disabled setting labelled coming soon |
| Per-patient Practitioner Prediction History | The implemented Practitioner History is a global Assessment History; Patient Details has no history query |
| `HEALTH_ASSESSMENT` ER entity | `HealthAssessmentModel` is a transient API request DTO and is not persisted |
| Separate `PATIENT` and `PRACTITIONER` entities | These are values of `USER.role` |
| Dashboard entity | Practitioner dashboard values are calculated dynamically |
| Recommendation entity | Recommendation text is part of each prediction response/document |
| Machine-learning model entity | The pipeline is an application artifact, not Firestore data |
| Legacy `/predict` and `heart_model.pkl` | Retained for compatibility but unused by the current Flutter workflow |
| Splash-screen activity | `SplashScreen` exists but is not connected to `MaterialApp.home` |

Search, filtering, sorting, and pagination remain internal behaviour of
`View Patient List`, not separate top-level use cases.

## Unresolved implementation uncertainties

- No previous UML or design-diagram files exist in the connected repository,
  so external diagrams cannot be compared visually without being supplied.
- FastAPI accepts the prediction request without Firebase token verification.
  The diagrams show the implemented behaviour and do not imply API
  authentication.
- Firestore does not enforce relational integrity. Practitioner History can
  therefore display `Unknown patient` for a prediction whose user profile is
  unavailable.
- `ResultScreen` uses route-stack navigation for `Return to Dashboard`; the
  diagrams model the successful result display, not a guaranteed named route.
- `PredictionScreen` itself displays an unauthenticated-user message rather
  than calling a Login route directly. The activity diagram's Login redirect
  represents the application-level signed-out routing performed by `AuthGate`.

## Mermaid rendering

### GitHub or compatible Markdown preview

Open each `.mmd` file in a Mermaid-capable editor, or copy its content into a
Markdown Mermaid block:

````text
```mermaid
<contents of the .mmd file>
```
````

### Mermaid Live Editor

1. Open <https://mermaid.live/>.
2. Paste the content of one `.mmd` file.
3. Export SVG or PNG for the report.

### Mermaid CLI without changing this repository

With Node.js installed, Mermaid CLI can be run on demand:

```powershell
npx.cmd --yes @mermaid-js/mermaid-cli -i docs/uml/use_case_diagram.mmd -o use_case_diagram.svg
npx.cmd --yes @mermaid-js/mermaid-cli -i docs/uml/activity_diagram.mmd -o activity_diagram.svg
npx.cmd --yes @mermaid-js/mermaid-cli -i docs/uml/sequence_diagram.mmd -o sequence_diagram.svg
npx.cmd --yes @mermaid-js/mermaid-cli -i docs/uml/er_diagram.mmd -o er_diagram.svg
```

Generated images should be kept outside the repository unless they are
explicitly required as report assets.

## Suggested figure captions

- **Figure 4.X CardioGuard Use Case Diagram**
- **Figure 4.X CardioGuard Patient Health Assessment and Prediction Activity Diagram**
- **Figure 4.X CardioGuard Heart Disease Prediction Sequence Diagram**
- **Figure 4.X CardioGuard Firestore Entity–Relationship Diagram**

The use-case specifications may be introduced as:

- **Table 4.X CardioGuard Use Case Specifications and Implementation Traceability**

## Minimal Chapter 4 paragraph updates

### System scope

> CardioGuard supports two authenticated human roles: Patient and Practitioner.
> Patients can register publicly, complete a cardiovascular assessment, obtain
> and review predictions, and access their own prediction history.
> Practitioners are provisioned outside public registration and can review
> dashboard summaries, Patient profiles, and the global assessment history.

### Prediction design

> The mobile application submits the 15 validated assessment values to the
> FastAPI `/predict/v2` endpoint. FastAPI constructs the ordered input frame and
> invokes the saved preprocessing and Random Forest Pipeline v2. After a
> successful response, the Flutter application generates a prediction UUID and
> saves the result to Cloud Firestore before displaying the Result Screen.

### Data design

> CardioGuard uses the top-level Firestore collections `users` and
> `predictions`. The Firebase Authentication UID identifies each user document,
> while each prediction uses a Flutter-generated UUID. The prediction `userId`
> forms a logical one-to-many association with the user `uid`; assessment input
> values are transient and are not stored.

### Practitioner-history scope

> The implemented practitioner history is a global Assessment History containing
> prediction records for all Patients. Selecting a linked record displays the
> patient and that selected prediction; a dedicated per-patient history screen
> is not implemented.

Chapter 5 does not require modification because these files document the
existing implementation and do not change application behaviour.
