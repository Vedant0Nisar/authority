# Complete API Documentation: Main Body (Authority) Module

This document provides a highly comprehensive, step-by-step, and technically detailed guide for the APIs supporting the **Main Body (Authority)** module in the Flutter application. It maps every API to its specific screen, defines the request-response behavior, and traces the data flow from the UI to the backend and back.

---

## 1. Authentication Configuration

**Global API Configuration:**

- **Base URL:** `http://<domain>:8001/api`
- **Default Headers:**
  - `Content-Type: application/json`
  - `Authorization: Bearer <JWT_TOKEN>` (Must be included in all authenticated requests)

---

## 2. Screen-Level API Mapping & Detailed Flow

### 2.1. Login Screen

The entry point for the Main Body user.

- **API 1:** `POST /users/login` (Standard Auth Endpoint)
- **Trigger:** User enters credentials and taps "Sign Into Portal".
- **Data Flow:** UI captures `email` and `password` → Validated locally for empty/format checks → Controller makes API call → Receives JWT token `{"access_token": "..."}` → Stores token securely locally (e.g., FlutterSecureStorage) → Updates global state (e.g., Provider/Riverpod) → Navigates to Dashboard.

#### API Details: User Login

- **Purpose:** Authenticate the Main Body authority and provide a session token.
- **HTTP Method:** `POST`
- **Full Endpoint URL:** `http://<domain>:8001/api/auth/login` (or equivalent backend login route)
- **Request Body:**

```json
{
  "email": "admin@gov.in",
  "password": "adminpassword123"
}
```

- **Sample Successful Response (200 OK):**

```json
{
  "success": true,
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "Main Authority",
    "role": "Main Body",
    "email": "admin@gov.in"
  }
}
```

- **Sample Error Response (401 Unauthorized):**

```json
{
  "detail": "Invalid credentials provided."
}
```

- **App Behavior:**
  - **Success:** Token is saved. Global Role is set to `Main Body`. Redirect to Dashboard.
  - **Error:** Hide loading spinner. Show a `SnackBar` displaying "Invalid credentials".

---

### 2.2. Dashboard Screen

The central reporting hub for the Main Body, presenting aggregate KPIs and recent tickets.

- **API 2:** `GET /tickets/stats`
- **API 3:** `GET /tickets`
- **Trigger:** Automatically invoked during the `initState()` or Riverpod `FutureProvider` when the Dashboard loads.
- **Data Flow:** Dashboard loads → Parallel API calls initiated (Stats & Tickets) → Show loading spinner → Receive JSON arrays/objects → Bind data to UI charts and lists.

#### API Details: Fetch Dashboard Statistics

- **Purpose:** Retrieve aggregate data for KPI cards (Open issues, Rework rate, etc.) and analytics charts.
- **HTTP Method:** `GET`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets/stats`
- **Sample Successful Response (200 OK):**

```json
{
  "open_tickets": 14,
  "closed_tickets": 42,
  "rework_rate": 5.2,
  "avg_resolution_days": 3.4
}
```

- **App Behavior:** Update KPI boxes for Main Body dashboard.

#### API Details: Fetch All Tickets

- **Purpose:** Retrieve the full list of tickets (defects) to populate the Map View, List View, and Recent Activity tables.
- **HTTP Method:** `GET`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets`
- **Sample Successful Response (200 OK):**

```json
[
  {
    "id": 105,
    "status": "NEW",
    "defect_type": "Pothole",
    "severity": "High",
    "location": "Sector 45, Main Road",
    "latitude": 21.1458,
    "longitude": 79.0882,
    "contractor": null,
    "created_at": "2026-03-02T10:00:00Z"
  }
]
```

- **Response Handling:** This list is cached in the local State Manager. The map markers and List view rows are built directly from this array.

---

### 2.3. Ticket Detail Screen & View Screens

Triggered when the Authority taps on a specific ticket from the List or Map. It loads rich details, including images, GPS coordinates, and historical activity.

- **API 4:** `GET /tickets/{id}`
- **Trigger:** Screen opens or is pulled-to-refresh.
- **Data Flow:** Route argument passes `ticketId` → Loader spins → Fetch API → Binds details, Before/After image URLs, and Activity Timeline to the screen.

#### API Details: Fetch Single Ticket Details

- **Purpose:** Get comprehensive details of a specific ticket, including its timeline, images, and AI analysis data.
- **HTTP Method:** `GET`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets/{id}`
- **Path Parameter:** `id` (integer) - The unique ID of the ticket.
- **Sample Successful Response (200 OK):**

```json
{
  "id": 105,
  "status": "INSPECTED",
  "defect_type": "Pothole",
  "severity": "High",
  "location": "Sector 45, Main Road",
  "latitude": 21.1458,
  "longitude": 79.0882,
  "contractor": "XYZ Contractors",
  "before_image": "https://<domain>/files/img1.jpg",
  "ai_processed_image": "https://<domain>/files/ai_img1.jpg",
  "after_image": "https://<domain>/files/img1_fixed.jpg",
  "activity_timeline": [
    {
      "timestamp": "2026-03-02T12:00:00Z",
      "action": "Technical Inspection Passed",
      "user": "Inspection Engineer"
    }
  ],
  "created_at": "2026-03-01T09:00:00Z"
}
```

- **App Behavior:** The app unpacks the JSON. If an image is null, it displays a placeholder. If `status` is `INSPECTED`, it reveals the "Final Verification" Action Panel.

---

### 2.4. Assignment Screen / Modal Popups

When a ticket Status is `NEW`, the Main Body must assign it to a Contractor.

- **API 5:** `GET /tickets/contractors` (Populates Dropdown)
- **API 6:** `PUT /tickets/{id}/assign` (Executes Assignment)
- **Trigger:** Authority taps 'Assign' -> Modal opens -> APIs execute.

#### API Details: Fetch Contractors List

- **Purpose:** Load available contractors into the assignment dropdown menu.
- **HTTP Method:** `GET`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets/contractors`
- **Sample Successful Response (200 OK):**

```json
[
  {
    "id": 1,
    "name": "XYZ Contractors"
  },
  {
    "id": 2,
    "name": "ABC Infrastructure"
  }
]
```

- **App Behavior:** Populates the `<DropdownButton>` choices in the Assignment Modal.

#### API Details: Assign Ticket to Contractor

- **Purpose:** Allocate a `NEW` ticket to a contractor, moving its status to `ASSIGNED`.
- **HTTP Method:** `PUT`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets/{id}/assign`
- **Path Parameter:** `id` (integer) - Ticket ID.
- **Request Body:**

```json
{
  "contractor": "XYZ Contractors"
}
```

- **Explanation of Request Keys:**
  - `contractor` (String): The exact name or ID of the contractor selected from the dropdown.
- **Sample Successful Response (200 OK):**

```json
{
  "success": true,
  "message": "Ticket successfully assigned to XYZ Contractors"
}
```

- **App Behavior (Success):** Close assignment modal → Show Success Snackbar → Trigger `fetchTicketById` to visually update the UI to status `ASSIGNED`.

---

### 2.5. Final Verification & Closure Workflows

When a contractor repairs the issue (`REPAIRED`) and an inspector passes it (`INSPECTED`), the Main Body sees the "Final Verification" panel. They can either **Approve & Close** or **Reject & Send for Rework**.

#### API Details: Approve and Close Ticket (Positive Path)

- **Purpose:** Final validation by the Main Body to move the ticket status from `INSPECTED` to `CLOSED`.
- **HTTP Method:** `PUT`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets/{id}/approve`
- **Path Parameter:** `id` (integer) - Ticket ID.
- **Request Body:** None.
- **Trigger:** Tapping "Verify & Close" button directly triggers the API.
- **Sample Successful Response (200 OK):**

```json
{
  "success": true,
  "message": "Ticket Closed Successfully."
}
```

- **App Behavior (Success):**
  - Status updates to `CLOSED`.
  - The simulated **Payment Modal** pops up:
    - _UI Action:_ Displays dummy payment amounts (e.g. ₹500 for Crack, ₹1000 for Pothole) with a 2.5-second simulated Processing Spinner.
    - _Post-Payment:_ Shows Success icon and Transaction ID. Closes and updates ticket list.

#### API Details: Reject & Send for Rework (Negative Path)

- **Purpose:** If the repair evidence is unsatisfactory, the Authority pushes the ticket back to the Contractor (`REWORK`).
- **HTTP Method:** `PUT`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets/{id}/rework`
- **Path Parameter:** `id` (integer) - Ticket ID.
- **Request Body:**

```json
{
  "role": "Main Body"
}
```

- **Explanation of Request Keys:**
  - `role`: Contextual variable indicating who rejected it, so the backend logs "Rejected by Main Body Authority" in the timeline.
- **Trigger:** Tapping the red "Reject & Send for Rework" button.
- **Sample Successful Response (200 OK):**

```json
{
  "success": true,
  "message": "Ticket moved back to Rework."
}
```

- **App Behavior (Success):** Shows Warning/Orange Snackbar ("Ticket sent for rework"). Updates UI state.

---

### 2.6. Reporting & Download Feature

Available dynamically on the Ticket Detail screen for record-keeping.

#### API Details: Download Evidence Pack

- **Purpose:** Export full ticket history, before/after images, and AI masks into a downloadable format (usually PDF or ZIP).
- **HTTP Method:** `GET`
- **Full Endpoint URL:** `http://<domain>:8001/api/tickets/{id}/evidence`
- **Browser/File Handling Behavior in Flutter:**
  - _Data Validation:_ URL generation appends a timestamp caching breaker (`?t=123...`).
  - _Workflow:_ UI calls the `url_launcher` package or downloads raw bytes into Flutter's `path_provider` directory. Once downloaded, triggers native file opener.

---

## 5. Summary of State Transitions Driven by APIs

For the **Main Body** module, tracking ticket status state transitions via API calls is the primary application objective:

1. **`NEW` → `ASSIGNED`**: Via `PUT /tickets/{id}/assign` (Executed strictly by Main Body's "Assign" modal).
2. `ASSIGNED` → `REPAIRED`: (Executed outside this module, by Contractor).
3. `REPAIRED` → `INSPECTED`: (Executed outside this module, by Inspector).
4. **`INSPECTED` → `CLOSED`**: Via `PUT /tickets/{id}/approve` (Exclusive Main Body Action).
5. **`INSPECTED` → `REWORK`**: Via `PUT /tickets/{id}/rework` (Exclusive Main Body Action).

## 6. General Implementation Instructions for Flutter Dev

- **Loading Architectures**: Wrap all `PUT` requests in `try/catch` and use `setState` or `Cubit` to toggle a `isLoading` overlay to `true` while the request resolves to prevent double submission.
- **Error Codes**:
  - `400 Bad Request`: Payload formatting error. Alert user safely.
  - `401 Unauthorized`: Token expired. Clear SecureStorage and redirect unconditionally to `LoginScreen()`.
  - `404 Not Found`: Ticket ID no longer valid. Pop to previous screen with a toast.
  - `500 Server Error`: Global backend failure. Suggest user to "Try again later."
- **Data Hydration**: Responses updating a ticket state should globally emit an event (e.g., via Bloc listener) so that if the user hits the Back Button, the `Dashboard` and `TicketList` re-fetch data rather than showing stale state.
