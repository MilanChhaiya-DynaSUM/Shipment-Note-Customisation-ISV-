# Shipment Note Management (BC24+)

A small Business Central extension that:

1. Adds a **Shipment Note Setup** table + card page.
2. Adds a **Shipment Note** entity (list/card, its own number series, a `Status` field with workflow validation).
3. Blocks **posting a Sales Order** when a new "Shipment Confirmed" checkbox on the order is unticked, via an event subscriber (no base-app code changed).
4. Ships with a **test codeunit** covering the status validation and the posting block.
5. Uses a mandatory **`ABC`** object prefix and is set up to be checked against **AppSourceCop** with the marketplace ruleset.

This repo is two separate AL projects, which is the standard AppSource-friendly layout:

```
app/    -> the shippable extension (no test dependencies)
test/   -> a separate test app: depends on app/
ruleset.json -> shared analyzer ruleset used by both projects
```

Keeping tests in their own app means the app you actually ship never pulls in
Microsoft's test-library dependency chain, which AppSource explicitly frowns on.

---

## Prerequisites

- VS Code with the **AL Language** extension.
- Access to a BC24 (or later) sandbox/container to download symbols and publish to.
- Node is not required; this is a pure AL project.

## First-time setup

1. Open `app/` as a folder in VS Code (a separate window for `test/` later).
2. `Ctrl+Shift+P` → **AL: Download Symbols/Dependencies** (needs a `launch.json` pointing at your sandbox — this file is intentionally not committed since it's per-developer/per-environment; VS Code will prompt you to create one on first launch, `F5`).
3. Update `app/app.json` → `publisher`, `privacyStatement`, `EULA`, `help`, `url` with your real company info before any real AppSource submission.
4. `F5` to publish/run in your sandbox.


## Running the analyzers (AppSourceCop)

In `app/.vscode/settings.json` the following are already enabled:

```json
"al.codeAnalyzers": ["${CodeCop}", "${UICop}", "${AppSourceCop}"]
```

`app/AppSourceCop.json` sets `"mandatoryAffixes": ["ABC"]`, so the analyzer will
fail the build if any object, field, or control is added without the prefix.
Run **AL: Package** or just build (`Ctrl+Shift+B`) — warnings/errors from all
three analyzers show up in the Problems pane. The goal delivered here is **zero
suppressions** in `ruleset.json`; if you ever need one, add it there with a
comment explaining why, rather than disabling analysis globally.

The `test/` app intentionally only runs `CodeCop` + `UICop` (see its
`.vscode/settings.json`) since Microsoft's own guidance is that test apps are
not submitted to AppSource and don't need to pass AppSourceCop.

## Running the tests

With the test app published to your sandbox, run it as usual:
`Ctrl+Shift+P` → **AL: Run current test** (or run the whole codeunit from the
Test Tool page in BC, filtering on codeunit `ABC Shipment Note Test`).

---

## What's inside

| Object | ID | Purpose |
|---|---|---|
| Table `ABC Setup` |  | Single-record config: number series code, whether shipment confirmation is enforced. |
| Page `ABC Setup Card` | 1000000 | Card page over the setup table. |
| Table `ABC Shipment Note` | 1000001 | The main entity: No., Description, Customer No., Shipment Date, Status. |
| Enum `ABC Shipment Note Status` | 1000000 | Open → Released → Closed. |
| Page `ABC Shipment Note List` / `Card` | 1000001 / 1000002 | Standard list + card, with Release/Close actions. |
| Table extension `ABC Sales Header Ext` | 1000000 | Adds `ABC Shipment Confirmed` (Boolean) to Sales Header. |
| Page extension `ABC Sales Order Ext` | 1000000 | Surfaces that checkbox on the Sales Order page so users can actually set it. |
| Codeunit `ABC Sales Post Subscriber` | 1000000 | Subscribes to `Sales-Post::OnBeforePostSalesDoc`; errors if the order isn't confirmed. |
| Permission set `ABC SHIP NOTE` | 1000000 | Grants RIMD on both tables + execute on the new pages/codeunit. |
| Codeunit `ABC Shipment Note Test` (test app) | 1000050 | 8 test methods, see below. |

Object ID ranges: main app `1000000–1000050`, test app `1000000–1000050` — chosen so
the two apps never collide if published side by side in the same environment.
Replace these with your AppSource-assigned range before real submission.

## Design choices

- **Number series via the `No. Series` codeunit**, not the legacy `NoSeriesManagement` codeunit — this is the BC22+ API and is what AppSourceCop / the platform expects going forward.
- **Status validation lives in a table procedure (`ValidateStatusChange`)**, not only in the field's `OnValidate` trigger. This makes it directly unit-testable and reusable from the Release/Close actions without going through `Validate()` twice.
- **Status transitions enforced:**
  - `Open → Released` requires Description, Shipment Date, and Customer No. to be filled in.
  - `Released → Closed` is allowed; `Open → Closed` is not (must release first).
  - Once `Closed`, the record is locked — no further status changes, including reopening.
- **Event subscriber over base-app modification.** The posting block is implemented purely via `[EventSubscriber]` on `Sales-Post::OnBeforePostSalesDoc`, so the base Sales Order posting codeunit is never touched — this is what makes the extension upgrade-safe and is a hard AppSource requirement.
- **The block is configurable**, not hardcoded: `ABC Setup."Require Shipment Confirmation"` lets an admin turn the rule off entirely (defaults to on).
- **Only Sales *Orders* are blocked** — Invoices, Credit Memos, Return Orders, etc. from the same posting codeunit are explicitly let through, since the requirement was scoped to orders.
- **Test app is separate from the shipping app** (see folder layout above), matching Microsoft's own AppSource sample apps, so `app/app.json` has zero dependencies and nothing in it needs the test-library toolkit.
- **`ABC` prefix everywhere**, including the permission set name and the new field/action names, per `AppSourceCop.json`'s `mandatoryAffixes`.

## Known gaps / things to revisit before a real AppSource submission

- `logo`, `privacyStatement`, `EULA`, `help`, and `url` in `app.json` are placeholders — AppSource submission requires real, reachable URLs and a logo image.
- No translation (`.xlf`) files are included; `"features": ["TranslationFile"]` is set so `AL: Generate Translation Files` will scaffold them.
- This was authored and reviewed by an AI assistant without access to a live AL compiler or BC24 container, so while the code follows the documented AL/AppSourceCop rules as of BC24, **please compile it and run the analyzers in your own environment before relying on it** — treat this as a strong first draft, not a pre-verified build.

