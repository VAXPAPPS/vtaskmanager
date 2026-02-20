# VTaskManager 🚀

**VTaskManager** is a professional, comprehensive desktop task management application (specifically optimized for Linux), built with Flutter and the **Vaxp-Template**, which provides modern and stunning Glassmorphism interfaces. The application is built following **Clean Architecture** principles to ensure scalability and maintainability.

---

## Key Features 🌟

1. **Modern Glassmorphic UI:** Design based on Glassmorphism aesthetics with interactive and dynamic animations.
2. **Clean Architecture:** Divided into layers (Domain, Data, Application, Presentation) to separate business logic from the UI and database.
3. **Dual Task Views:**
   - **List View:** A traditional list supporting swipe-to-delete functionality.
   - **Kanban Board:** Visual task representation (Todo, In Progress, Done) with **Drag & Drop** support to easily move tasks between states.
4. **Comprehensive Category System:** Create custom categories by choosing a name, color (from a wide palette), and icon.
5. **Subtasks:** Add subtasks to any task and view a progress bar indicating the completion percentage.
6. **Priority Management:** Assign priorities (Urgent, High, Medium, Low) to tasks with visual badges and color coding.
7. **Due Dates Management:** Clear indicators and distinct coloring for overdue tasks.
8. **Smart Search & Filtering:** Full-text search alongside advanced filtering (by status, priority, and/or category).
9. **Dashboard & Statistics:**
   - Summary of task counts and a circular completion rate indicator.
   - Detailed charts using Pie Charts for status distribution, Bar Charts for priorities, and progress bars for category distribution.
10. **Desktop Environment Integration:** Features custom sidebar navigation and a seamlessly integrated custom Title Bar.

---

## Core Dependencies 📦

The application is built on the latest and best Flutter ecosystem technologies, primarily relying on:

- **State Management:**
  - `flutter_bloc` & `bloc`: For robust and decoupled event and state management across the app.
  - `equatable`: For easy comparison of entity and state objects.
- **Local Storage:**
  - `hive` & `hive_flutter`: A lightweight, lightning-fast NoSQL database operating without the need for code generation (No Code Gen) to avoid SDK conflicts.
- **UI & Analytics:**
  - `fl_chart`: For rendering professional pie and bar charts in the statistics view.
  - `window_manager`: For desktop window control (hiding the native title bar, setting dimensions).
- **Utilities:**
  - `uuid`: For generating accurate, unique IDs for tasks and categories.
  - `intl`: For readable date formatting and relative dates (Today, Yesterday).
  - `venom_config`: Theme and configuration management package specific to the Vaxp template.

---

## Prerequisites 🛠️

Ensure your development environment is set up for Linux desktop:

1. **Flutter SDK** installed and updated.
2. Enable Linux Desktop Development:
   ```bash
   flutter config --enable-linux-desktop
   ```
3. Essential development libraries for Linux/Ubuntu:
   ```bash
   sudo apt-get install clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
   ```

---

## How to Run 🚀

1. Navigate to the project directory and fetch packages:
   ```bash
   flutter pub get
   ```

2. Run the application in Debug Mode:
   ```bash
   flutter run -d linux
   ```

3. Build a release executable:
   ```bash
   flutter build linux
   ```
   > The final executable release build will be saved at:
   > `build/linux/x64/release/bundle/vtaskmanager`

---
*VAXP Organization — Private Project.

