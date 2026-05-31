# Calmora Application: End-to-End Functional QA Audit Report

This report presents a thorough, functional QA audit of the Calmora Flutter mental wellness application. Every module, screen, action button, data flow, and calculation has been traced back to its underlying code to evaluate features, missing connections, hardcoded blocks, and bug prioritizations.

---

## # WORKING FEATURES

| Feature Area | Result / Verification Details |
| :--- | :--- |
| **Authentication & Profile Setup** | Onboarding is fully functional. Profile registration enables customizing patient/clinician roles, avatar icons (`avatarIconCodePoint`), avatar color (`avatarColorValue`), and DOB. |
| **App Lock Gate** | Pin authentication is fully integrated. If an app lock is set, the lock gate screen is triggered after timeouts, securely validating inputs against `lockPin`. |
| **Session & Data Persistence** | Full `AppSession` is stored locally. State changes trigger an automatic JSON serialization to the SQLite database `app_session.db` (Table: `session_store`) which loads cleanly on app boot. |
| **On-Demand Role Switching** | Toggling between Patient and Psychologist roles via settings or dashboard instantly transitions the active UI layout, menus, and dashboards reactively. |
| **Journal creation & history** | Reflection logs support manual saving, stream-of-consciousness writing, and 2-second debounced autosaves. Displays chronologically in lists. |
| **Journal sharing with Psychologist** | "Share with provider" switch successfully updates `sharedWithPsychologist = true`. Shared journals render immediately in the Psychologist's dashboard. |
| **Calmora AI Provider Routing** | Toggling AI modes (`Auto`, `Calmora (Ollama)`, `Gemini`) redirects chat queries accurately. Gemini API keys are loaded securely from `.env` and `SecureStorageService`. |
| **AI Fallback & Quota Logs** | Auto mode transitions from Ollama (primary) to Gemini (secondary) on server timeout. Rate-limit status codes (429) print exhaustion details rather than generic errors. |
| **Typing Cadence Tracking** | During the typing test, characters per second, words per minute, and backspace rates are tracked in real time. |
| **Typing Stress Score Contribution** | Typing stress scores (0.0 to 1.0) contribute directly to the patient's core state by updating the Drift Index in memory: `(profile.driftIndex + stressScore) / 2.0`. |
| **Breathing timers & animations** | Breathing exercises support navy SEAL Box, 4-7-8, Coherent, and Physiological Sigh breathing guides with breathing halo animations. |
| **Doctor Recommendations** | Recommends doctors by categories (Clinical Psychologist, Psychiatrist, Therapist, Counselor). High stress levels sort Dr. Webb to the top. |
| **Appointment Booking Flow** | Selecting recommended slots opens a note entry card, registers a pending appointment block in `AppSession`, and persists it securely. |
| **Psychologist Appointment Approvals** | Psychologist dashboard shows pending requests. Clicking "Approve" confirms the session (`confirmed = true`). |
| **Psychologist Medication Prescribing** | Clinicians can select medicines (using auto-complete search of standard remedies), attach reminder alarm times, add instructions, and issue prescriptions. |
| **Local Reminders Service** | Registers daily local notification alarms for scheduled mood check-ins and prescribed medicine hours via `NotificationService`. |
| **Theme & Privacy Settings** | Switching between Light, Dark, and cursive Journal themes is fully functional. Privacy configurations, policies, and app PIN timeout sliders work. |

---

## # PARTIALLY WORKING FEATURES

* **7-Day Trend Graph**: 
  * *Status*: Partially Functional.
  * *Details*: Dynamically plots entries for days that contain logs (`90 - (avgMood - 1.0) * 18`), but uses a hardcoded variation array (`baseDrift + variations[dayIndex % 7]`) to mock and simulate data if logs are missing for any weekday.
* **AI Chat typing signals**:
  * *Status*: Partially Functional.
  * *Details*: Displays real-time updates of speed, backspaces, and avg pause on the dashboard, but these statistics are mock calculations derived directly from the current Drift Index (`profile?.driftIndex`) rather than retrieved from a typing test history database.
* **AI Breathing Recommendation**:
  * *Status*: Partially Functional.
  * *Details*: Breath Coach accurately reads `profile?.driftIndex` to recommend specific exercises (e.g. Physiological Sigh for critical stress), but completing the breathing cycle has zero downstream feedback effect on reducing the Drift Index.

---

## # BROKEN FEATURES

* **Edit & Delete Mood Check-ins**:
  * *Exact Failure*: Completely unimplemented. Mood log cards in the list do not contain edit or delete buttons, and `AppSessionNotifier` lacks methods to modify/delete mood logs.
* **Patient Appointment Cancellation**:
  * *Exact Failure*: Completely unimplemented. Patients have no cancel or delete triggers for requested or confirmed appointments in the UI.
* **Prescription Editing and Deletion**:
  * *Exact Failure*: Completely unimplemented. Once a prescription is drafted by a psychologist, there are no UI widgets or actions to edit or delete it.
* **Medication Adherence Tracking**:
  * *Exact Failure*: Entirely missing. The patient's care panel lacks checking/completion mechanisms to log when daily medicine reminders are complied with.
* **Psychologist Notes Management**:
  * *Exact Failure*: The psychologist dashboard lacks diary logs or note diaries to save and review clinical session notes for active patients.
* **Clinician Weekly Reports View**:
  * *Exact Failure*: Clinicians have zero capability to access or read the patient's weekly clinical wellness reports.
* **Appointment Notifications**:
  * *Exact Failure*: `NotificationService` completely lacks scheduling triggers to alert patients of upcoming doctor appointments.
* **Wellness & Breathing History Logs**:
  * *Exact Failure*: Completed breathing sessions are never persisted in local storage or logged into a history list.
* **Ollama Endpoint & Model Selectors**:
  * *Exact Failure*: The Settings UI has no input fields or model selectors to change the `OLLAMA_ENDPOINT` or Ollama model name.

---

## # MISSING DATA FLOW CONNECTIONS

* **Mood Logging → Drift Index Recalculation**:
  * *Expected Behavior*: Logging "Terrible" mood checks should adjust the overall stress index upwards, and "Excellent" should shift it downwards.
  * *Actual Behavior*: `addMoodEntry` updates streaks and records the log, but has zero downstream impact on updating `profile.driftIndex`. The central gauge and the weekly report card remain unaffected by mood logs.
* **Breathing Exercise Completion → Stress Level Reduction**:
  * *Expected Behavior*: Completing a Box or 4-7-8 breathing session should decrease `profile.driftIndex`.
  * *Actual Behavior*: The timers complete, but no downward adjustment is sent to the Drift Index, leaving the dashboard gauge at an elevated level.
* **Typing Stress Test → History Storage**:
  * *Expected Behavior*: Completing the typing test should persist results (WPM, accuracy, corrections, date) in a history log.
  * *Actual Behavior*: Results are displayed in a completion modal dialog and average score updates `driftIndex` in memory, but the individual test run statistics are never saved to local database history.

---

## # HARDCODED / MOCK FEATURES

* **Weekly AI Report Summaries**:
  * *Evidence*: Generating the report triggers a fake loop with 700ms progress delays, after which the clinical report and actionable steps are loaded from a **static local block of hardcoded text** mapped to three pre-designed Drift Index thresholds (<0.35, <0.65, >=0.65). No AI API call is performed.
* **Report Sharing & PDF Exporting**:
  * *Evidence*: Clicking "Share" or "Export PDF" does not construct files or transmit data; they only show success snackbar notifications.
* **Dashboard Hesitation and Typing Metrics**:
  * *Evidence*: Dashboard "Avg Pause" and "Backspace Rate" grid tiles are derived from the overall Drift Index via mathematical scales (e.g. `0.2 + drift * 1.2` for pause) rather than referencing typing history logs.
* **Psychologist Active Patients List**:
  * *Evidence*: Dynamically aggregates unique names from confirmed bookings but defaults to a single static "Demo Patient" card.

---

## # HIGH PRIORITY BUGS

1. **Disconnect between Mood Log and Drift Index Gauge**: Users check in their mood daily, but the central progress arc gauge and clinical metrics do not reflect these check-ins.
2. **Lack of Appointment Cancellation / Deletion**: Patients are locked out of canceling future scheduled sessions, and clinicians cannot remove or reject slots.
3. **No Appointment Alarms**: Patients are never notified of upcoming clinical appointments, leading to missed therapy slots.
4. **Missing Ollama Configurations in Settings**: Ollama server endpoint and custom model name inputs are missing from Settings, blocking standard self-hosting configurations.

---

## # LOW PRIORITY BUGS

1. **Infinity Breathing Immersive Cycle**: Guided breathing cycles loop infinitely without a target limit or completion summary modal.
2. **Missing Prescription Edits/Deletes**: Clinicians cannot edit prescription instructions or delete expired prescriptions.
3. **Unpersisted Breathing/Wellness Sessions**: Wellness history remains empty as completed breathing sessions are never logged.

---

## # RECOMMENDED FIXES (Prioritized Checklist)

- [ ] **1. Connect Mood Log to Drift Index System**: Modify `addMoodEntry` in `AppSessionNotifier` to recalculate `profile.driftIndex` based on mood logs (e.g. terrible mood increases drift, excellent mood decreases drift).
- [ ] **2. Implement Appointment Cancellation & Deletion**: Add delete buttons inside `_showAppointmentDetails` in `_AppointmentCard` and implement corresponding deletions in `AppSessionNotifier`.
- [ ] **3. Integrate Appointment Reminders**: Add local notification scheduling inside the appointment request flow in `appointments_screen.dart` via `NotificationService`.
- [ ] **4. Build Ollama Settings Inputs**: Add text input fields in the "Calmora AI" settings section to configure the Ollama endpoint and model names.
- [ ] **5. Integrate Real AI Weekly Reports**: Refactor `WeeklyReportScreen` to call the `aiManager` rather than displaying hardcoded text blocks, and generate actual PDFs for exporting.
- [ ] **6. Persist Typing Test and Breathing Logs**: Extend `AppSession` and `AppSessionNotifier` with `typingHistory` and `wellnessHistory` lists and save results on completion.
- [ ] **7. Enable Prescription Modifications**: Provide edit and delete controls inside the Psychologist dashboard's prescription card list.
