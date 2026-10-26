# Credit Manage Book

A simple iOS app for shopkeepers to record what customers owe, accept partial or full payments, and always know the outstanding balance. All amounts are in Indian rupees (₹).

## Features

**Home** — Dashboard with quick actions (Add Customer, Add Credit) and summaries such as total outstanding, credit given and payments received, and customers with the highest dues.

**Details** — Customer list and per-customer detail: total credit, total paid, outstanding balance, and full transaction history (credits and payments). Record partial or full payments here.

**Products** — Add, edit, and deactivate the shop's products (name, price, unit). Products are picked when adding a credit.

## Core behaviour

- Customers can have multiple credit transactions, each made of one or more product items.
- Item prices are saved at the time of sale, so later price changes never alter past records.
- Payments can be partial or full; outstanding balance = total credit − total payments.
- Deleting a customer also deletes their credits and payments, after confirmation.

## Tech

- Swift, SwiftUI, MVVM
- SwiftData for local storage
- iOS 17+
- No third-party dependencies

## Project structure

```
Credit Manage Book/
├── CLAUDE.md
├── README.md
├── Docs/                    Architecture, data model, workflow
└── Credit Manage Book/      App sources
    ├── Models/
    ├── Custom/
    ├── Screens/
    ├── TabBar/
    └── Utilities/
```

## Documentation

- [Architecture](Docs/ARCHITECTURE.md)
- [Data model](Docs/DATA_MODEL.md)
- [Development workflow](Docs/DEVELOPMENT_WORKFLOW.md)

## Getting started

Open `Credit Manage Book.xcodeproj` in Xcode and run the app on an iOS simulator.

## Status

Project scaffold only; features are not yet implemented.
