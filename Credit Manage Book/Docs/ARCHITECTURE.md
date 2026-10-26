# Architecture

SwiftUI + MVVM + SwiftData, iOS 17+. Current state: scaffold only (`Credit_Manage_BookApp.swift`, `ContentView.swift`). Folders below are the target layout under `Credit Manage Book/Credit Manage Book/`.

## Folders

```
Models/       SwiftData @Model types
Custom/       Reusable UI components
Screens/      One folder per feature: View + ViewModel (+ private subviews)
TabBar/       Root TabView
Utilities/    Constants, extensions, formatters, helpers
```

### Models/
`Customer`, `Credit`, `CreditItem`, `Product`, `Payment`. Stored data and simple derived values only. See @DATA_MODEL.md.

### Custom/
Shared components used by more than one screen: text fields (including a rupee amount field), primary/secondary buttons, `ToastView`, empty-state view, card/row styles. Components take values and closures; they never touch SwiftData or ViewModels.

### Screens/
```
Screens/
├── Dashboard/        DashboardView, DashboardViewModel
├── Customers/        Customer list/detail, add/edit customer, payments, history
├── Credits/          Add credit (customer + product selection)
└── Products/         Product list, add/edit product
```
Add a feature folder only when a feature exists. Each screen has `XxxView.swift` and `XxxViewModel.swift`. Sub-screens and sheets live in the same feature folder.

### TabBar/
`MainTabView.swift`: a `TabView` with three tabs — **Home** (Dashboard), **Details** (customers), **Products**. The app entry point shows `MainTabView` and attaches the SwiftData `modelContainer`.

### Utilities/
`AppConstants` (strings, spacing, limits), a shared INR currency formatter, `Decimal` rounding helper, date formatting, small `View`/`String` extensions. Keep it small; no catch-all dumping.

## MVVM responsibilities

| Layer | Does | Does not |
|---|---|---|
| View | Layout, bindings, forwards actions | Calculations, validation rules, saving |
| ViewModel | `@Observable`; screen state, validation, fetch/insert/update, balance calculations, error messages | Import SwiftUI views or layout types |
| Model | `@Model` stored properties, relationships, simple computed totals | UI, navigation, formatting |

- A View creates/owns its ViewModel (`@State`) and passes in `ModelContext` from `@Environment(\.modelContext)`.
- Simple read-only lists may use `@Query` in the View; filtering, sorting with logic, and all writes go through the ViewModel.
- Balance and total calculations live in one place (model computed properties or one ViewModel helper) and are reused, never reimplemented in Views.

## Navigation

- One `NavigationStack` per tab, using `navigationDestination(for:)` with value-based links (e.g. the customer's `PersistentIdentifier` or the model).
- Forms (Add Customer, Add Credit, Add Payment, Add Product) are presented as sheets from the screen that triggers them.
- Dashboard quick actions present the same sheets as their home screens; don't build duplicate forms.
- Switching tabs programmatically (e.g. from Dashboard to a customer) uses a selection binding held by `MainTabView`.

## Feedback and errors

Validation errors show inline; operation results (saved, deleted, failed) show via `ToastView`. ViewModels expose a message/state; Views display it.

## Reuse rules

1. Check `Custom/` and `Utilities/` before writing new UI or helpers.
2. Promote a component to `Custom/` when a second screen needs it, not before.
3. Avoid protocols, generic wrappers, and service layers unless clearly required.
