# OttoPhix — Automotive Service Management System

A Flutter-based automotive service management application built for managing vehicle service operations, task assignments, inventory tracking, customer requests, and workshop workflows.

The system supports multiple user roles including customers, mechanics, and managers, allowing each user to access features tailored to their responsibilities. OttoPhix integrates authentication, service scheduling, task management, inventory control, and progress tracking through a centralized Supabase backend.

## Highlights

- Developed a full-stack workshop management system using Flutter and Supabase.
- Implemented role-based access for customers, mechanics, and managers.
- Built service request and appointment tracking workflows.
- Created task management tools for assigning and monitoring repair tasks.
- Integrated inventory and stock management with audit logging.
- Added authentication, password recovery, and deep-link based account actions.
- Implemented realtime database interactions through Supabase.

## Technical Implementation

### Architecture

The project separates authentication, service management, task tracking, inventory management, and user interfaces into focused modules:

```text
Application
├── Authentication
│   ├── LoginPage
│   ├── SignUpPage
│   ├── ForgotPasswordPage
│   └── ResetPasswordPage
│
├── Navigation
│   ├── HomePage
│   ├── HistoryPage
│   └── AccountPage
│
├── Service Management
│   ├── ServicePage
│   ├── AddServicePage
│   ├── Service
│   ├── Car
│   └── ServiceAssignment
│
├── Task Management
│   ├── TaskMain
│   ├── TaskDetailPage
│   ├── TaskSummaryPage
│   ├── TaskInfoPage
│   ├── NewTaskForm
│   └── EditTaskForm
│
├── Inventory System
│   ├── SearchPage
│   ├── DetailPage
│   ├── CartPage
│   ├── StockPage
│   └── InventoryLogPage
│
└── Backend Services
    ├── Supabase Authentication
    ├── DatabaseService
    ├── File Management
    └── Deep Link Handling
```

### User Management

The application supports multiple user roles:

- **Customer**
  - View service requests
  - Track repair progress
  - Manage vehicles

- **Mechanic**
  - View assigned services
  - Update service status
  - Manage repair tasks

- **Manager**
  - Create and assign services
  - Monitor workshop operations
  - Oversee service progress

### Service Management

The service management system allows users to:

- Create service requests
- Track service progress
- Assign mechanics to jobs
- Manage vehicle information
- Monitor service status changes

Supported service statuses include:

- Pending
- In Progress
- On Hold
- Reviewing
- Completed

### Task Management

Each service can contain multiple repair tasks.

Features include:

- Task creation
- Task editing
- Task assignment
- Progress tracking
- Service-specific task filtering
- Task summaries and reporting

### Inventory Management

The inventory module provides:

- Spare part catalog browsing
- Product search functionality
- Stock quantity monitoring
- Inventory adjustments
- Inventory transaction logging
- Item tracking and management

### Authentication and Security

The system uses Supabase Authentication to provide:

- User registration
- Login functionality
- Password reset workflows
- Deep-link authentication callbacks
- Session management

## Features

### Service Tracking

- Service request creation
- Vehicle registration
- Service status updates
- Customer progress tracking
- Mechanic assignments

### Task Management

- Create repair tasks
- Edit and update tasks
- Track task completion
- Service-linked task organization

### Inventory Control

- Product catalog management
- Search and filtering
- Stock adjustment tools
- Inventory audit logs

### Account Management

- User authentication
- Password recovery
- Profile management
- Role-based access control

## Technology Stack

- Flutter
- Dart
- Supabase
- SQLite
- Material Design
- Firebase Configuration
- RESTful Database Operations

### Packages Used

- `supabase_flutter`
- `image_picker`
- `app_links`
- `intl`
- `uuid`
- `file_picker`
- `open_filex`
- `sqflite`

## Building the Project

### Requirements

- Flutter SDK 3.x
- Dart SDK
- Android Studio or VS Code
- Supabase Project
- Android SDK

### Steps

1. Clone the repository:

```bash
git clone https://github.com/yourusername/ottophix.git
```

2. Navigate to the project folder:

```bash
cd ottophix
```

3. Install dependencies:

```bash
flutter pub get
```

4. Configure Supabase credentials.

5. Run the application:

```bash
flutter run
```

## Technical Highlights

- Implemented a role-based automotive service management platform using Flutter and Supabase.
- Built authentication flows including login, registration, password recovery, and deep-link callbacks.
- Developed service tracking workflows for customers, mechanics, and managers.
- Implemented task management features with service-specific task assignment and progress monitoring.
- Created inventory management functionality with stock adjustments and audit logging.
- Integrated Supabase database operations for realtime service, account, task, and inventory data.
- Implemented search and filtering systems for services, products, and inventory records.
- Structured the application using modular Flutter pages and reusable data models.
- Utilized SQLite support for local data storage and persistence where required.

## Screenshots

### Login Screen

![Login Screen](screenshots/login.png)

### Dashboard

![Dashboard](screenshots/dashboard.png)

### Service Management

![Service Management](screenshots/service-management.png)

### Task Tracking

![Task Tracking](screenshots/task-tracking.png)

### Inventory Management

![Inventory Management](screenshots/inventory-management.png)

### Account Management

![Account Management](screenshots/account-management.png)

## Author

Developed as a Flutter mobile application for automotive workshop management, service tracking, task assignment, and inventory control using Supabase as the backend platform.
