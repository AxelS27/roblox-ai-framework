# Badges Domain Spec

---

## 🎖️ Badge List

| Badge Name | Description / Requirement | Trigger Condition (Technical) | Asset ID |
| :--- | :--- | :--- | :--- |
| `[e.g., Veteran Sailor]` | `[e.g., Travel 10,000 studs downstream.]` | `[e.g., Player profile stat TravelDistance matches or exceeds 10,000]` | `[Asset ID]` |
| `[Badge Name]` | `[Requirement]` | `[Trigger]` | `[Asset ID]` |

---

## 🛠️ Verification & Implementation
* **Server-Authoritative**: All badges must be awarded via server-side scripts checking achievement states.
* **pcall Wrappers**: Always wrap `BadgeService:AwardBadge()` calls in `pcall` blocks to handle API outages safely.
