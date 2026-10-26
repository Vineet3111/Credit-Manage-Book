# Development Workflow

Rules for any future change to this project.

## 1. Inspect first

- List the project structure and read every file you will touch, plus neighbouring files in the same folder, before editing.
- Search for existing components in `Custom/` and helpers in `Utilities/` before writing new ones.
- Read the relevant doc: @ARCHITECTURE.md for structure, @DATA_MODEL.md for data and money.
- Check existing documentation before creating or changing any; never overwrite it blindly.
- If the request conflicts with these docs or is ambiguous in a way that affects data or money, ask before coding.

## 2. Plan briefly

For anything beyond a small fix, state which files will be created or changed and why. Keep the change as small as the request allows; no unrelated refactors.

## 3. Implement

- Follow MVVM: View → ViewModel → Model. Put each file in the right folder; one type per file.
- New screens: `Screens/<Feature>/XxxView.swift` + `XxxViewModel.swift`.
- Reuse `Custom/` components and `Utilities/` helpers first; extend before duplicating. Add to `Custom/` only for components clearly reused in many places.
- Split large Views into subviews declared inside the same View file (see "Subviews and reuse" in @ARCHITECTURE.md). No separate file per subview.
- Use iOS 17-compatible, non-deprecated APIs only. No new dependencies without approval.
- Follow the money rules: `Decimal`, shared INR formatter, price snapshots, derived balances.
- Don't hand-edit `project.pbxproj`; new files on disk are picked up automatically (synchronized group).
- Keep Swift code consistent with surrounding style; avoid speculative abstractions and duplicated logic.

## 4. Test and verify

- Build the app for an iOS simulator and fix all warnings and errors you introduced.
- Add unit tests for ViewModel logic and balance calculations (use an in-memory `ModelContainer`). Cover at least: line totals, partial payment, full payment, overpayment rejection, price change after sale not altering history, inactive product behaviour, customer delete cascade, ₹ formatting.
- Add SwiftUI `#Preview`s for new views, using in-memory sample data.
- Run the app and exercise the changed flow in the simulator; check empty, long-text, and large-amount states, light and dark mode.
- Don't claim something works unless it was built or run; report what was and wasn't verified.

## 5. Finish

- Re-read the diff for leftover debug code, unused files, and deprecated APIs.
- Update the docs in the same change if structure, models, or rules changed.
- Summarize what changed, what was tested, and any open questions. Commit only when asked.

## Safety

- Never delete or rewrite user financial data in migrations or "cleanup" code without explicit approval.
- Schema changes to released models require a migration plan.
