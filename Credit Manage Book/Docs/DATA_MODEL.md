# Data Model

SwiftData, iOS 17+. Models live in `Models/`. Money is `Decimal`, rounded to 2 places, in INR.

## Models

| Model | Purpose | Key properties |
|---|---|---|
| `Customer` | A person who buys on credit | name, phone (optional), address/notes (optional), createdAt, isArchived |
| `Credit` | One credit transaction (a sale on credit) | date, note (optional), customer, items |
| `CreditItem` | One line in a credit | product (optional link), productName, unitPrice, quantity |
| `Product` | Shop item available for selection | name, currentPrice, isArchived, createdAt |
| `Payment` | Money received from a customer | amount, date, note (optional), customer, credit (optional) |

All models have a stable unique id (`UUID`) in addition to SwiftData's persistent identifier.

## Relationships

```
Customer 1 ──< Credit 1 ──< CreditItem >── 0..1 Product
Customer 1 ──< Payment >── 0..1 Credit
```

- `Customer.credits` and `Customer.payments`: to-many, inverse set explicitly.
- `Credit.items`: to-many, **cascade** delete (items have no meaning without their credit).
- `CreditItem.product`: optional, **nullify** on product delete; never cascade.
- `Payment.credit`: optional, **nullify**.
- Always declare `@Relationship(inverse:)` on one side, and set relationships by assigning the model, not by copying IDs.
- Give relationship arrays a default of `[]` and make to-one links optional (SwiftData requirement for safe migration).

## Preserving history

- `CreditItem` stores **snapshots**: `productName` and `unitPrice` are copied from the product when the item is created. Editing a product later never changes existing items.
- Products with history are **archived** (`isArchived = true`), hidden from selection, not deleted. Hard delete is allowed only for a product never used.
- Customers with any credit or payment are **archived**, not deleted. Hard delete only when they have no records.
- Credits and payments are not silently edited. Corrections are made by an explicit edit/delete action with confirmation; deleting a credit removes its items and recalculates balances.

## Money rules

- Type: `Decimal`. Never `Double`/`Float` anywhere in money paths, including parsing input (parse text with a `Decimal` format style/`Decimal(string:locale:)`).
- Round to 2 decimal places with one rounding mode (`.plain`) defined in a shared `Utilities` helper; use it for every stored amount.
- Quantity is an `Int` (or `Decimal` if fractional units such as kg are needed — decide once and document it here).
- Amounts must be positive; a payment may not exceed the current outstanding balance unless the user explicitly chooses to record an advance (decide and document; default: reject).
- Display with the shared INR formatter (`en_IN` locale, ₹, Indian digit grouping, e.g. ₹1,23,456.50).

## Calculations

All derived, never stored as editable fields:

```
CreditItem.lineTotal      = unitPrice × quantity
Credit.total              = Σ items.lineTotal
Credit.paid               = Σ payments linked to that credit
Credit.outstanding        = Credit.total − Credit.paid
Customer.totalCredit      = Σ credits.total
Customer.totalPaid        = Σ payments.amount   (linked or not)
Customer.outstanding      = totalCredit − totalPaid
Dashboard.totalOutstanding = Σ Customer.outstanding
```

## Payments

- **Partial**: any amount > 0 and ≤ outstanding.
- **Full**: amount equals the customer's current outstanding.
- A payment belongs to a customer; linking it to a specific credit is optional. Unlinked payments reduce the customer total only. Customer-level outstanding is always the source of truth for "how much does this customer owe".
- Transaction history = credits and payments merged and sorted by date (newest first).

## Queries and performance

- Fetch with `FetchDescriptor`/`@Query` and sort descriptors; avoid loading all records to filter in memory when a predicate works.
- `#Predicate` has limited support for computed properties and `Decimal` math, so compute totals in code after fetching the relevant records.
- Create the `ModelContainer` once in the app entry point with all five model types. Schema changes after release need a `VersionedSchema` migration plan.
