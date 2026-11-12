# FixaBoda

FixaBoda is a rider-to-mechanic roadside assistance platform. The project combines a Flutter mobile app, a React admin dashboard, and a Spring Boot backend to support on-demand vehicle assistance.

## Project overview

This repository contains three main parts:

- Mobile app: `fixa_boda/`
  - Built with Flutter
  - Used by riders and mechanics
  - Handles sign-up, sign-in, onboarding, service requests, and live tracking

- Admin dashboard: `fixa_boda_admin/`
  - Built with React + Vite
  - Displays riders, mechanics, service requests, and operational metrics

- Backend API: `fixa_boda_backend/`
  - Built with Java + Spring Boot + JPA + PostgreSQL
  - Provides authentication, role-based access, service request management, and admin reporting

## How the system works

1. A user registers in the mobile app as either a rider or a mechanic.
2. The backend creates the account and issues a JWT token on login.
3. A rider creates a service request with a request type, pickup location, and issue description.
4. The backend stores the request and exposes nearby available mechanics.
5. A mechanic can accept the request and update its status.
6. The rider and mechanic can monitor the live route snapshot and estimated journey details.
7. The admin dashboard reads data from the backend to track active users and service volumes.

## Main functionalities

### Mobile app (`fixa_boda`)

- Role-based onboarding for rider and mechanic
- User registration and login
- Email verification flow
- Rider request creation for breakdown or roadside help
- Nearby mechanic lookup
- Request acceptance by mechanics
- Status updates such as pending, accepted, and completed
- Live route information with rider and mechanic coordinates
- Basic rider and mechanic dashboards

### Admin dashboard (`fixa_boda_admin`)

- Overview of total riders, mechanics, verified mechanics, and available mechanics
- Operational statistics for open, accepted, and completed requests
- Rider and mechanic listings
- Role-based summary and monitoring panel

### Backend API (`fixa_boda_backend`)

- JWT authentication and role authorization
- User registration/login endpoints
- Rider request creation and retrieval
- Mechanic request retrieval and acceptance
- Availability and location updates
- Service request status updates
- Admin summary dashboard
- PostgreSQL data persistence with JPA

## Tech stack

- Flutter
- Dart
- React
- Vite
- Java 17
- Spring Boot 3.3.1
- Spring Security
- JPA / Hibernate
- PostgreSQL
- Maven

## Prerequisites

Before running the project, install:

- Flutter SDK 3.12+
- Java 17+
- Maven 3.9+
- Node.js 18+
- PostgreSQL 14+

## Database setup

Create a PostgreSQL database named `fixaboda`:

```sql
CREATE DATABASE fixaboda;
```

Update the database credentials if needed in:

- `fixa_boda_backend/src/main/resources/application.properties`

The default configuration is:

```properties
jdbc.url=jdbc:postgresql://localhost:5432/fixaboda
jdbc.username=postgres
jdbc.password=postgres
server.port=8081
```

## Run the backend

From the repository root:

```bash
cd fixa_boda_backend
mvn spring-boot:run
```

This starts the Spring Boot app on:

- http://localhost:8081

The API is exposed under `/api`.

Example routes include:

- `/api/auth/register`
- `/api/auth/login`
- `/api/rider/requests`
- `/api/mechanic/requests/{mechanicId}`
- `/api/admin/dashboard/summary`

## Run the admin dashboard

From the repository root:

```bash
cd fixa_boda_admin
npm install
npm run dev
```

Then open the URL shown in the terminal, typically:

- http://localhost:5173

## Run the mobile app

From the repository root:

```bash
cd fixa_boda
flutter pub get
flutter run
```

### Important note for Android emulator

The Flutter app is configured to call the backend using:

```dart
http://10.0.2.2:8081/api
```

This works correctly with the Android emulator. For a physical device or local browser environment, the base URL may need to be changed to `http://localhost:8081/api`.

## Recommended local startup order

1. Start PostgreSQL
2. Start the backend
3. Start the admin dashboard
4. Start the Flutter app

## Example user flow

- Register a rider
- Log in as that rider
- Create a service request
- Log in as a mechanic
- View incoming jobs
- Accept a request
- Update the request status
- Review the metrics in the admin dashboard

## Project structure

```text
.
├── README.md
├── fixa_boda/              # Flutter mobile app
├── fixa_boda_admin/        # React admin dashboard
├── fixa_boda_backend/      # Spring Boot API
└── .git/                   # Git metadata
```

## Notes

This is a full-stack prototype for a transport/roadside support marketplace. It is intended for local development and demonstration, and the application and security settings are suitable for a development environment rather than production deployment.
