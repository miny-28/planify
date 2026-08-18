                                                  planify architecture 


1. Application Layers

1.1 Presentation Layer

Responsible for everything the user interacts with.
الجزء ده خاص بكل اليوزر بيتعامل معاه

Main screens:

login
sign Up
profile
home / dashboard
tasks
add Task
tasks Details
schedule
availability
settings


1.2 Authentication & User Management Layer

Responsible for user accounts, authentication, and profile management.

ده مسئول عن الاكونتس لكل يوزرس

Responsibilities:

Create user accounts.
Sign in users.
Sign out users.
Manage user sessions.
Manage user profiles.
Store user-specific preferences.
Associate tasks and schedules with the correct user.
Ensure each user can access only their own data.

Main components:

Authentication Manager
User Manager
Profile Manager


1.3 Business Logic Layer

    ده الجزء الخاص بكل القرارات والقواعد الخاصه بالجدول (كل الوجيك و الأوامر )
Responsible for the main application logic and decision-making.

Responsibilities:

Validate task information.
Manage task status.
Calculate task priority.
Apply scheduling constraints.
Generate schedules.
Handle dynamic schedule recalculation.
Handle scheduling edge cases.


1.4 Data Layer

ده المسئول عن تخزين كل الداتا ال بتدخل لل ابلكيشن

Responsible for storing and retrieving application data.

Main data:

Users
User Profiles
Tasks
Schedule Slots
User Availability
User Preferences

                                   -------

Planify Architecture
│
├── Presentation Layer
│   └── Screens & User Interaction
│
├── Authentication & User Management
│   ├── Authentication Manager
│   ├── User Manager
│   └── Profile Manager
│
├── Business Logic Layer
│   ├── Task Manager
│   ├── Priority Calculator
│   ├── Smart Scheduling Engine
│   ├── Schedule Manager
│   └── Availability Manager
│
└── Data Layer
├── Users
├── Profiles
├── Tasks
├── Schedule Slots
├── Availability
└── Preferences