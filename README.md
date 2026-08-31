# PennyPal

PennyPal is a student-focused personal finance app prototype built with Swift and SwiftUI. It gives college students a simple, friendly way to review sample income and expenses, monitor category budgets, and explore spending trends.

## Current functionality

- Launch screen with navigation to log in or create an account.
- Firebase Authentication for account creation, sign-in, and password-reset requests.
- Client-side validation for email addresses and passwords. Passwords must be at least eight characters and include an uppercase letter, number, and symbol.
- Optional demo-account shortcut on the login screen (using the configured Firebase account).
- Home dashboard with a calculated balance, income and expense totals, and the five most recent transactions.
- Overview dashboard with income and expense totals, a spending bar chart, weekly/monthly/yearly filters, an income/expense toggle, and budget summaries.
- Add Entry screen for recording an expense or income with an amount, title/source, category, and optional note.
- Built-in income and expense categories, plus custom categories created from the Add Entry screen.
- Budgets dashboard showing sample category limits, spending, remaining amounts, and progress indicators.
- Profile dashboard showing the signed-in user’s account details, calculated balance, entry count, preferred currency, join date, and sign-out action.
- Bottom tab navigation between Home, Overview, Add Entry, Budgets, and Profile.
- Sample transactions, categories, and budgets so the signed-in dashboard can be explored immediately.

## Current limitations

Authentication is connected to Firebase, but the app does not currently restore an existing Firebase session on launch or persist first and last names to the user profile. Transactions, budgets, and custom categories are held in view state and are initialized from sample data for each dashboard session; they are not persisted between launches or synchronized across devices. Budgets are currently display-only: there is no UI for creating, editing, or deleting budget limits. There is also no goals feature yet.

## Project status

PennyPal is an in-progress learning project for practicing iOS development while building a useful budgeting tool for students. The next major step is persistent, user-specific storage for transactions, categories, and budgets, followed by budget management and goals.
