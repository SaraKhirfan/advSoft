# FinTrack – Finance Tracking Mobile Application

FinTrack is a mobile application that helps users track their expenses, income, budgets, and financial tasks.
It was developed as part of the **Advanced Software Engineering** course at the **University of Jordan**, completed in **May 2025**.

---

## ✨ Features

### User & Security

* User registration and login
* Firebase Authentication
* Password reset
* Profile editing
* Secure session handling

### Budgeting

* Budget rule selection: 50/30/20, 70/20/10, 30/30/30/10
* Automatic category allocation
* Updating budget amount
* Balance updates after each transaction
* Warnings at 75% of category usage
* Alerts when exceeding category limits

### Transactions

* Add income and expenses
* Categorize transactions
* View transaction history
* Detailed transaction view

### Tasks

* Create, edit, and delete tasks
* Mark tasks as complete
* Task categories
* Reminder settings

### Financial Overview

* Total balance
* Total income and total expenses
* Category usage indicators
* Summary messages and statistics

### Resources

* Financial resources section
* Budget recommendation survey

---

## 💻 Tech Stack

| Component        | Technology                                     |
| ---------------- | ---------------------------------------------- |
| Framework        | Flutter                                        |
| Language         | Dart                                           |
| Backend          | Firebase (Auth, Firestore, Messaging, Storage) |
| Design           | Figma                                          |
| State Management | Provider                                       |

---

## 🛠️Architecture Overview

The system is divided into four main subsystems:

1. User & Security Management
2. Budget & Finance Engine
3. Task & Notification Center
4. Content & Resources Hub

This structure makes the system easy to maintain and expand.

---

## 🎯Main Implementation Highlights

### Authentication

* Registration and login through Firebase
* Email/password validation
* Session persistence

### Budget Service

* Converts selected rules into percentage allocations
* Stores budget rules in Firestore
* Validates rules when retrieved or updated

### Finance Tracker

* Computes balance, category usage, and budget warnings
* Provides data to the UI through ChangeNotifier

### Transactions

* Adds income and expenses
* Handles category mapping
* Retrieves transaction history with sorting
* Real-time Firestore stream support

### State Management

* Provider architecture
* Separation between logic and UI
* Clear loading and error states

---

## ⚙️Testing

Test cases cover:

* Registration and login flow
* Budget rule setup
* Income and expense transactions
* Budget warnings
* Task creation and completion
* Profile updates
* Password changes
* Session and logout behavior
* First-time user flow
* Survey recommendation logic

---

## 📚Development Process

* Agile approach
* Weekly meetings
* Task management on Notion
* Documentation and diagrams included in the project report

---

## ⌛Future Enhancements

* Bank account integration
* Advanced analytical reports
* Exporting data (CSV/PDF)
* Multi-currency support
* Automated insights



