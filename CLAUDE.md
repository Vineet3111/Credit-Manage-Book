# Credit Manage Book

iOS app for shopkeepers to track customer credit (udhaar), payments, and outstanding balances in Indian rupees (₹).

## Detailed docs

- @Docs/ARCHITECTURE.md — folders, MVVM, navigation, reusable components
- @Docs/DATA_MODEL.md — SwiftData models, relationships, payments, money rules
- @Docs/DEVELOPMENT_WORKFLOW.md — how to inspect, implement, and test changes

## Stack

- Swift + SwiftUI, MVVM, SwiftData. Do not use UIKit at all.
- Minimum deployment target: **iOS 17**. Use only current, supported APIs; never deprecated ones (e.g. use `NavigationStack`, `#Preview`, `foregroundStyle`).
- No third-party dependencies unless the user explicitly approves one.
- Xcode project root: this folder. App sources: `Credit Manage Book/` (inside it). The project uses a file-system synchronized group, so files added on disk under it are picked up by Xcode automatically — never edit `project.pbxproj` by hand.
- Known discrepancy: `project.pbxproj` currently sets `IPHONEOS_DEPLOYMENT_TARGET = 26.1` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. The intended target is iOS 17. Do not change it silently; ask the user first. Do not use APIs newer than iOS 17 without `#available` handling.

## Folder layout (under `Credit Manage Book/`)

`Models/` · `Custom/` · `Screens/<Feature>/` · `TabBar/` · `Utilities/` — see @Docs/ARCHITECTURE.md for contents and rules.

## Coding rules

- **Views** render state and forward user actions. No business logic, no calculations, no direct `modelContext` writes.
- **ViewModels** (`ObservableObject` with `@Published` properties, one per screen; never `@Observable`) own screen state, validation, and all writes/queries. Name `XxxView` / `XxxViewModel`; keep them in the same feature folder.
- **Models** (`@Model`) hold stored data and simple derived values only. No UI or navigation code.
- Use `@Query` in Views only for simple, read-only lists; anything with logic goes through the ViewModel.
- One type per file; file name matches the type. Prefer small, focused files over large ones.
- **Reuse first.** Before writing any UI or helper, search `Custom/` and `Utilities/`. Put something in `Custom/` only if it is a reusable component clearly needed in many places (buttons, text fields, toast, rows used on several screens). Do not put single-screen pieces or tiny wrappers (e.g. an amount label, a one-screen summary card) in `Custom/`.
- **Keep screens readable.** Break a screen into subviews, but declare them **inside the same View file** as private computed properties or small private functions (e.g. `private var header: some View`), grouped under `// MARK: - Subviews`. `body` should read like an outline. Do not create a separate file per subview.
- Only the screen's top-level View talks to its ViewModel.
- Reuse logic the same way: shared calculations, formatting, and validation live once in `Utilities/` or the model, never copied per screen.
- Never use `navigationTitle`. Every pushed screen hides the system nav bar (`.toolbar(.hidden, for: .navigationBar)`) and shows `CustomNavBar` from `Custom/`. Use `AppTextField` for form fields, `AppButton` for save/confirm actions, and `ToastView` for save feedback, shown with `.overlay { if viewModel.showToast { ToastView(message:style:isPresented:) } }` (`ToastStyle.success` green or `.error` red; no View extension). Forms stay open after saving and clear their fields.
- Constants (strings, spacing, keys) go in `Utilities/`, not scattered literals.
- Prefer `async`/`await` over callbacks. Avoid force unwraps and `try!`; handle errors and surface them via `ToastView`.
- Don't add abstractions (protocols, generic layers, repositories) until a second real use case needs them.
- Match the style of surrounding code: naming, comment density, formatting.

## Money rules (critical)

- Never use `Double`/`Float` for money. Use `Decimal`, rounded to 2 decimal places.
- Format with the INR currency format style and `en_IN` locale (₹ with Indian digit grouping). One shared formatter in `Utilities/`.
- Never mutate or recompute historical records from current product prices. Credit items store a price snapshot.
- Outstanding balance is always derived (credits − payments), never stored as a free-standing editable value. Details in @Docs/DATA_MODEL.md.

## Do not

- Let product edits or deletion change saved credit items; items keep their own copied values.
- Delete a customer (which deletes their credits and payments) without user confirmation.
- Duplicate balance logic in Views or multiple ViewModels.
- Create documentation or files not asked for.
- Modify existing files without reading them first.
- Write complex code. Keep it simple and readable.

## Workflow

Inspect first, change minimally, build and test before reporting done. Full rules in @Docs/DEVELOPMENT_WORKFLOW.md.
