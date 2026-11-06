# 💜 SkillSwap – Share Skills. Learn Together.

**SkillSwap** is a student-focused skill exchange iOS application designed to encourage peer-to-peer learning within college campuses. It allows students to connect with one another, share their knowledge, teach skills they already possess, and learn new skills from fellow students.

The application creates a collaborative campus environment where learning goes beyond classrooms and students can grow together by exchanging knowledge.

---

## 📱 Project Overview

SkillSwap provides a platform where students can:

- Showcase the skills they can teach.
- Discover skills they want to learn.
- Explore other students and their profiles.
- Send and manage skill exchange requests.
- Find preferred meeting locations on an interactive campus map.
- Connect with fellow students who share similar learning interests.

---

## ✨ Features

### 1. User Authentication
- Student registration and login.
- Firebase Authentication for secure account management.
- Individual student accounts.

### 2. Student Profile Management
- Create and edit student profiles.
- Add personal information, course, academic year, and bio.
- Add skills to teach and skills to learn.
- Select a preferred campus meeting location.

### 3. Skill-Based Discovery
- Explore student profiles.
- Discover students based on their teaching skills.
- View other students' skills, interests, and academic details.
- Find potential skill exchange partners.

### 4. Skill Swap Requests
- Send requests to other students.
- Select the skill you are offering and the skill you wish to learn.
- View sent and received requests.
- Accept or decline incoming requests.
- Track request statuses: Pending, Accepted, and Declined.

### 5. Campus Map Integration
- Interactive campus map powered by Apple MapKit.
- Displays the college campus location.
- Shows registered students who have saved preferred meeting coordinates.
- Select student map markers to view their profiles.
- Helps students coordinate in-person learning sessions.

### 6. Demo Student Profiles
- Sample student profiles for demonstration purposes.
- Explore the application without relying entirely on real student data.
- Demo profiles can receive requests but cannot accept or decline them without authenticated accounts.

### 7. Cloud Database
- Firebase Cloud Firestore integration.
- Stores student profiles and skill information.
- Stores and retrieves skill swap requests.
- Supports profile updates and request status changes.

### 8. Validation and Error Handling
- Prevents students from sending requests to themselves.
- Validates selected skills against student profiles.
- Checks for duplicate pending requests.
- Provides error messages for invalid actions and failed operations.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Swift | Application programming language |
| SwiftUI | User interface development |
| Firebase Authentication | User authentication |
| Firebase Firestore | Cloud database |
| Apple MapKit | Interactive campus map |
| CoreLocation | Geographic coordinates and location data |
| Xcode | iOS development environment |

---

## 🏗️ Application Architecture

SkillSwap follows a layered approach to separate the user interface, application logic, and database operations.

**1. Presentation Layer – SwiftUI**
- Displays application screens.
- Handles user interactions.
- Provides navigation and visual components.

**2. Application Logic Layer – AppData**
- Manages shared application state.
- Loads student profiles and requests.
- Validates skill swap requests.
- Coordinates application operations.

**3. Data Access Layer – FirestoreService**
- Communicates with Firebase Firestore.
- Saves and retrieves student profiles.
- Creates and updates swap requests.

**4. Backend Layer – Firebase**
- Firebase Authentication manages user accounts.
- Cloud Firestore stores application data.

### Data Flow

Student → SwiftUI Views → AppData → FirestoreService → Firebase Firestore

---

## 🗂️ Project Structure

The project is organized into the following major Swift files:

| File | Description |
|---|---|
| `SkillSwapApp.swift` | Application entry point |
| `ContentView.swift` | Main application navigation |
| `Models.swift` | Student and swap request data models |
| `AppData.swift` | Shared application state and business logic |
| `AuthService.swift` | Authentication operations |
| `AuthView.swift` | Login and registration interface |
| `FirestoreService.swift` | Firebase database operations |
| `HomeView.swift` | Home screen |
| `ExploreView.swift` | Student discovery screen |
| `StudentCard.swift` | Reusable student profile card |
| `StudentDetailView.swift` | Detailed student profile and swap request interface |
| `RequestsView.swift` | Sent and received swap requests |
| `ProfileView.swift` | Student profile creation and editing |
| `CampusMapView.swift` | Interactive campus map |
| `Theme.swift` | Shared application styling |

---

## 🔥 Firebase Database Structure

The application uses Cloud Firestore with the following collections:

### `students`
Stores registered student profiles.

Example fields:
- `name`
- `course`
- `year`
- `bio`
- `initials`
- `skillsToTeach`
- `skillsToLearn`
- `preferredMeetingSpot`
- `preferredLatitude`
- `preferredLongitude`

### `demoStudents`
Stores sample student profiles used for demonstration.

### `swapRequests`
Stores skill exchange requests.

Example fields:
- `senderId`
- `receiverId`
- `offeredSkill`
- `requestedSkill`
- `status`
- `createdAt`

### `liveLocations`
Reserved for optional live location sharing functionality. Its use depends on the implementation and appropriate privacy permissions.

---

## ⚙️ Installation and Setup

### Prerequisites

- macOS
- Xcode
- An iOS Simulator or compatible iPhone
- An active Firebase project
- Firebase iOS SDK

### Steps to Run the Project

**1. Clone the repository**

```bash
git clone https://github.com/Ved05nara/SkillSwap.git
```

**2. Open the project**

Open the SkillSwap Xcode project or workspace.

**3. Configure Firebase**

- Create a Firebase project.
- Register an iOS application using the project's bundle identifier.
- Download the `GoogleService-Info.plist` file.
- Add the configuration file to the Xcode project.
- Enable Email/Password authentication.
- Create a Cloud Firestore database.
- Configure the required Firestore Security Rules.

**4. Resolve Dependencies**

Ensure the Firebase SDK dependencies are installed through Swift Package Manager.

**5. Build and Run**

- Select an iOS Simulator or connected iPhone.
- Build the project.
- Run the application from Xcode.

---

## 🔐 Security and Privacy

- Firebase Authentication is used for account management.
- Firestore Security Rules control access to database collections.
- Students select their preferred meeting locations.
- The campus map displays saved meeting coordinates rather than automatically tracking users.
- Location-related functionality should follow user consent and appropriate access restrictions.

---

## 🚀 Future Enhancements

Potential improvements for future versions include:

- AI-powered skill recommendations.
- Intelligent student matching.
- In-app messaging between students.
- Session scheduling and calendar integration.
- Push notifications for swap requests.
- Student ratings and feedback.
- Verified college student accounts.
- Consent-based live location sharing.

---

## 🎯 Project Objective

The primary objective of SkillSwap is to promote collaborative learning and knowledge sharing among college students.

By creating a platform where students can exchange skills, discover learning partners, and coordinate campus meetups, SkillSwap aims to make education more interactive, accessible, and community-driven.

---

## 👨‍💻 Developed For

**K. J. Somaiya School of Engineering**  
Vidyavihar, Mumbai, Maharashtra, India.

**Project:** SkillSwap – A Peer-to-Peer Skill Exchange Platform

---

## 💜 Learn More. Do More. Together.

*SkillSwap – Building a community where every student has something to teach and something to learn.*
