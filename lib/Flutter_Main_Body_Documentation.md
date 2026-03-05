# Main Body Module - Flutter Application Technical Documentation

## 1. Complete Functional Documentation (Main Body All Screens)

### 1.1. Login Screen

- **Purpose**: Authenticate users (Inspector, Contractor, Authority/Main Body) and secure the portal.
- **Detailed Description of all UI components**:
  - Logo/Header banner.
  - Welcome text.
  - Email input field.
  - Password input field.
  - Sign Into Portal button.
  - Demo accounts informative section.
- **Field Names**: `email`, `password`.
- **Field Types**: Text Field (Email), Text Field (Password, obscureText: true).
- **Field Validation Rules**:
  - `email`: Required, must be a valid email format.
  - `password`: Required, cannot be empty.
- **Field Functionality**: Captures user credentials to generate an auth token.
- **Button Actions and Behavior**: "Sign Into Portal" validates inputs, calls the login API, and navigates to Dashboard on success. Shows error snackbar on failure.
- **State Management Logic**: Local widget state holds the input values (`isLoading` for button spinner). On success, updates global `AuthContext` (or equivalent provider/Riverpod/Bloc) with user details and token.
- **Navigation Flow**: On success -> Navigate to `/dashboard` (Dashboard Screen) replacing the current route.
- **Complete Screen Workflow**: User opens app -> views Login -> enters details -> validates locally -> API call -> if success, stores token locally and navigates to Dashboard; if fail, displays error.

### 1.2. Dashboard Screen

- **Purpose**: Central hub showing Key Performance Indicators (KPIs), analytical charts, and recent ticket activity.
- **Detailed Description of all UI components**:
  - Header (User Role, Logout).
  - Command Bar (Search, Role indicator, Create Defect button for Inspectors).
  - KPI/Action Cards (Open/Closed stats, Rework Rate).
  - Analytics Charts (Status Distribution).
  - Quick Repair Modal (for Contractors).
- **Field Names**: `searchTerm` (Search Bar), `repairTicketId` (Dropdown), `repairFileList` (Image Upload), `repairNotes` (Text Area).
- **Field Types**: TextField (Search), Dropdown/Select (Ticket selection), FilePicker/ImagePicker, TextArea.
- **Field Validation Rules**: Search (Optional). Repair Modal: `repairTicketId` (Required), Image (Required, Image type only), `repairNotes` (Optional).
- **Field Functionality**: Search filters dashboard data locally. Repair fields capture data for quick repair submission.
- **Button Actions and Behavior**:
  - "Create Defect" -> Navigates to Create Defect screen.
  - "Submit Repair" -> Calls quick repair API and refreshes dashboard on success.
- **State Management Logic**: Fetches `tickets` and `summary` from APIs on init. Filtered data is computed based on `activeRole` and `searchTerm`.
- **Navigation Flow**: Click "Create Defect" -> `/create-defect`, Click KPI Card -> `/tickets` with pre-filled filters.
- **Complete Screen Workflow**: Dashboards loads -> Fetches summary and tickets -> Calculates KPIs based on role -> User searches or clicks to navigate.

### 1.3. Ticket List Screen

- **Purpose**: Displays a tabular view of all tickets with filtering and search capabilities. Provide quick actions.
- **Detailed Description of all UI components**:
  - Filter Bar (Status dropdown, Severity dropdown, Search input).
  - Data Table / List View (ID, Status, Type, Location, Severity, Actions).
  - Action Buttons (Document View, Quick Assign, Quick View Modal).
- **Field Names**: `filterStatus`, `filterSeverity`, `searchTerm`.
- **Field Types**: Dropdown, Text Field.
- **Field Validation Rules**: None (all optional filters).
- **Field Functionality**: Updates local list of displayed tickets.
- **Button Actions and Behavior**: "View" opens modal or Details screen. "Assign" opens assignment modal (Authority only).
- **State Management Logic**: Local state for filters and selected ticket. Global state/Provider for fetching `tickets` list.
- **Navigation Flow**: Click "Document/View" -> `/ticket/:id` (Ticket Detail).
- **Complete Screen Workflow**: Screen loads -> fetched tickets -> User applies filters -> List updates instantly -> User clicks a ticket to view details.

### 1.4. Create Defect Screen

- **Purpose**: Allow Inspectors to log a new road defect with AI analysis via image capture and geolocation.
- **Detailed Description of all UI components**:
  - Defect Type Dropdown.
  - Description Text Area.
  - Severity Dropdown.
  - Location Pinpoint Widget (Latitude/Longitude read-only fields).
  - Refetch Location Button.
  - Image Upload/Camera Picker.
  - Submit Ticket Button.
  - AI Analysis Confirmation Modal.
- **Field Names**: `defect_type`, `description`, `severity`, `location` (lat/lng), `before_image`.
- **Field Types**: Dropdown, TextArea, Dropdown, TextFields (read-only), ImagePicker.
- **Field Validation Rules**: `defect_type` required, `severity` required, `location` required (must have lat/lng), `before_image` required (valid image under 5MB).
- **Field Functionality**: Gathers defect details. Location auto-fetches using GPS. Image is converted to Base64 for the API.
- **Button Actions and Behavior**:
  - "Refetch Location" -> Queries GPS again.
  - "Submit Ticket" -> Triggers AI analysis API -> Shows Analysis Modal -> User confirms -> Calls Create Ticket API.
- **State Management Logic**: Holds form data, `locationData` (lat/lng), Base64 image string, and AI analysis result object.
- **Navigation Flow**: On Successful Creation -> Navigate back to `/dashboard`.
- **Complete Screen Workflow**: User opens screen -> GPS automatically fetched -> User fills details & captures image -> Submits -> AI analyzes image -> User reviews AI mask -> Confirms submission -> Uploads to backend.

### 1.5. Ticket Detail Screen

- **Purpose**: Display full lifecycle, details, images, and action panels for a specific ticket.
- **Detailed Description of all UI components**:
  - Ticket Summary Card.
  - Action Panel (Role-based: Assign, Upload Repair, Technical Inspect, Final Verify, Submit Rework).
  - Defect Images (Original + AI Mask).
  - Repair Evidence (After Image).
  - Activity Timeline.
- **Field Names**: `selectedContractor` (Dropdown), `after_image` (Image Picker), `repair_notes` (TextArea), `reworkNotes` (TextArea).
- **Field Types**: Dropdown, ImagePicker, TextArea.
- **Field Validation Rules**: Actions require corresponding fields (e.g., `after_image` and `repair_notes` are required for submitting a repair).
- **Field Functionality**: Contextual forms for changing ticket state.
- **Button Actions and Behavior**:
  - "Assign" (PUT Assign API).
  - "Submit Repair" (PUT Repair API).
  - "Approve" (PUT Inspect/Approve API).
  - "Rework" (PUT Rework API).
- **State Management Logic**: Fetches single ticket ID details on init. Manages local loading states for action buttons.
- **Navigation Flow**: Back Button -> Navigate to `/tickets` maintaining previous filters.
- **Complete Screen Workflow**: Loads ticket by ID -> Renders role-specific action panel -> User performs action -> API called -> Refreshes ticket data immediately.

### 1.6. Map View Screen

- **Purpose**: Visually plot defects on a map for spatial analysis.
- **Detailed Description of all UI components**:
  - Interactive Map widget (Google Maps or Mapbox).
  - Map Markers (Color-coded by severity).
  - Floating Filters Widget (Road, Status, Severity).
  - Ticket Detail Drawer (Bottom sheet or side pane).
- **Field Names**: `selectedRoad`, `statusFilter`, `severityFilter`.
- **Button Actions and Behavior**: Clicking a map marker opens the drawer/bottom sheet with ticket details.
- **Navigation Flow**: Dashboard <- Map View -> Ticket Detail.

---

## 2. UI Workflow Documentation

### A. UI Flow & Logic

- **User Journey**:
  1. Login -> Validates and assigns role (Inspector, Contractor, Authority).
  2. Lands on Dashboard -> Sees overview.
  3. Action: If Inspector, clicks "Create Defect" -> logs new issue -> goes back to Dashboard.
  4. Action: Authority checks "Ticket List" -> filters by "NEW" -> selects ticket -> "Assigns" to Contractor.
  5. Action: Contractor logs in -> filters by "ASSIGNED" -> views Ticket Detail -> uploads repair proof -> status updates to "REPAIRED".
  6. Action: Inspector logs in -> verifies "REPAIRED" -> approves to "INSPECTED" (or sends for "REWORK").
  7. Action: Authority logs in -> final verification of "INSPECTED" -> approves to "CLOSED".
- **Business Logic Explanation**:
  - Tickets have strict states: `NEW` -> `ASSIGNED` -> `REPAIRED` -> `INSPECTED` -> `CLOSED`. (`REWORK` loops back to Contractor).
  - Roles limit actions: Only Authority can assign. Only Contractor can upload repairs. Only Inspector does technical inspection. Only Authority closes.
- **Data Handling & State Updates**:
  - Forms update local state -> submitted via REST API -> on success `fetchTickets` or `fetchTicketById` is called to sync UI with backend.
- **Error Handling Flow**:
  - Network errors/HTTP 4xx-5xx trigger globally handled Snackbars/Toast messages.
  - Invalid tokens trigger immediate logout and redirection to Login.

### B. Field-Level Functional Flow

- **Location Fields (Create Defect)**: Automatically queries device GPS. If successful, populates Lat/Lng read-only fields. Formats into string `"lat, lng"` for API submission. Does reverse geocoding to display a human-readable address.
- **Image Uploads**: Converts device File to Base64 (or multipart form in Flutter) before passing to `analyzeTicket` or `submitRepair`. Checks file size (< 5MB) and type (Images only) locally before API transmission.
- **Conditional Visibility**: Action panels in `TicketDetail` are explicitly driven by `activeRole` AND `ticket.status`. Example: The "Assign Contractor" dropdown only mounts if `role == 'Main Body'` AND `status == 'NEW'`.

---

## 3. Complete API Documentation (For Each Screen)

**Global Headers for all requests:**

- `Content-Type: application/json`
- `Authorization: Bearer <T0KEN>`

### 3.1. Fetch Tickets

- **Purpose**: Get all tickets for Dashboard/List/Map.
- **HTTP Method**: GET
- **Endpoint URL**: `http://<domain>:8001/api/tickets`
- **Request Body**: None.
- **Sample Success Response**:

```json
[
  {
    "id": 1,
    "status": "NEW",
    "defect_type": "Pothole",
    "severity": "High",
    "location": "12.34, 56.78",
    "latitude": 12.34,
    "longitude": 56.78,
    "road_id": null,
    "contractor": null,
    "before_image": "base64...",
    "after_image": null,
    "created_at": "2026-03-02T10:00:00Z"
  }
]
```

- **App Action**: Updates global tickets list, updates Dashboard KPIs.

### 3.2. Fetch Single Ticket

- **Purpose**: Load Ticket Details.
- **HTTP Method**: GET
- **Endpoint URL**: `http://<domain>:8001/api/tickets/{id}`
- **Sample Success Response**: Single JSON object matching the ticket schema above. Includes `activity_timeline` array.

### 3.3. Create Ticket

- **Purpose**: Submit a new defect.
- **HTTP Method**: POST
- **Endpoint URL**: `http://<domain>:8001/api/tickets/`
- **Request Body**:

```json
{
  "road_id": null,
  "location": "12.34, 56.78",
  "latitude": 12.34,
  "longitude": 56.78,
  "description": "Deep pothole",
  "defect_type": "Pothole",
  "severity": "High",
  "before_image": "base64_string",
  "ai_processed_image": "base64_string"
}
```

- **App Action**: Form resets, navigates to Dashboard, shows Success snackbar.
- **Error Response (400)**: `{"detail": "Invalid location format"}` -> shows Error Snackbar.

### 3.4. Analyze Ticket (AI)

- **Purpose**: Pre-process image to find defects.
- **HTTP Method**: POST
- **Endpoint URL**: `http://<domain>:8001/api/tickets/analyze`
- **Request Body**: `{"image": "base64...", "defect_type": "Pothole"}`
- **Sample Success Response**:

```json
{
  "detections": 1,
  "original": "base64...",
  "processed": "base64...",
  "length_cm": 15,
  "width_cm": 10,
  "density": 85
}
```

- **App Action**: Opens AI modal for user to confirm before calling Create Ticket.

### 3.5. Ticket Actions (Assign / Repair / Inspect / Approve / Rework)

- **Assign (PUT)**: `/api/tickets/{id}/assign` | Body: `{"contractor": "Name"}`
- **Repair (PUT)**: `/api/tickets/{id}/repair` | Body: `{"after_image": "base64...", "repair_notes": "fixed"}`
- **Inspect (PUT)**: `/api/tickets/{id}/inspect` | Body: None
- **Approve (PUT)**: `/api/tickets/{id}/approve` | Body: None
- **Rework (PUT)**: `/api/tickets/{id}/rework` | Body: `{"role": "Inspector"}`
- **Sample Success Response**: `{"msg": "Ticket updated successfully"}`
- **App Action**: Reloads Ticket Detail data and shows Success snackbar.

---

## 4. Overall System Workflow

- **End-to-End Flow**:
  1. _Input_: Inspector captures field data via Create Defect Form.
  2. _Validation_: App validates location, AI analyzes the image.
  3. _API_: Data posted to Backend.
  4. _Response -> Storage_: Backend saves it, App fetches updated list to State.
  5. _Display_: Pothole displays on Dashboard and Map.
  6. _Assignment_: Authority views it on Ticket List, assigns it.
  7. _Repair_: Contractor sees assignment, acts on it, uploads physical fix via Form -> translates to API PUT.
  8. _Validation Chain_: Inspector -> Authority verifies through API PUT transitions.
  9. _Closure_: Ticket marked CLOSED. Data persists in DB, Timeline updated.

- **Screen Connections**:
  - `Login` navigates to `Dashboard` on auth success.
  - `Dashboard` contains buttons to `CreateDefect`, `TicketList`, `MapView`.
  - Maps and Lists both navigate to `TicketDetail` when an item is tapped.
  - `TicketDetail` actions resolve and pop navigator back to List/Dashboard.

- **Error Handling Strategy**:
  - Global interceptor for API calls. If 401 Unauthorized -> Logout.
  - Try/Catch blocks wrapping API methods returning `{"success": false, "error": "message"}`.
  - UI components read the `success` boolean to trigger either navigation or a UI Error Dialogue.
  - Device errors (Permission denied for Camera/GPS) are caught locally and prompt the user gracefully.
