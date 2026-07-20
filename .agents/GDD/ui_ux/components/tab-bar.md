# UI Component Blueprint: Tab Bar / Category Selector

> [!NOTE]
> Component for switching between main UI categories (e.g. Hair vs Shirts vs Pants in Customization, or Weapons vs Items in Inventory).

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type TabItem = {
    Id: string,
    Title: string,
    IconId: string?,
}

export type TabBarProps = {
    Tabs: { TabItem },
    DefaultTabId: string,
    OnTabSelected: ((selectedTabId: string) -> ())?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Tab Bar Header Container - Size {1, 0, 0, 40})
├── UIListLayout (FillDirection: Horizontal, Padding: 6px)
└── Frame (Tab Button Item - Repeats per tab)
    ├── UICorner (CornerRadius: UDim.new(0, 8))
    ├── UIStroke (Thickness: 1px)
    ├── UIListLayout (FillDirection: Horizontal, VerticalAlignment: Center, Padding: 6px)
    ├── ImageLabel (Tab Icon)
    ├── TextLabel (Tab Title)
    └── Frame (Active Indicator Line - Anchored at Bottom, Size {1, 0, 0, 3})
```

---

## 🎨 Visual Design Tokens & States

| Tab State | Fill Color | Indicator Line | Text Color |
| :--- | :--- | :--- | :--- |
| **Inactive Tab** | `#141418` (Transparency: `0.5`) | Hidden | `#888899` |
| **Hover Tab** | `#202028` (Transparency: `0.3`) | Hidden | `#cccccc` |
| **Active Tab** | `#2a2a36` | `#00aaff` (Sky Blue) | `#ffffff` (Bold) |

---

## 🎭 Tab Switching Animations
* **Tab Click:** Active indicator line slides horizontally underneath the newly selected tab (`Tween EasingStyle: Quad Out, 0.2s`).
* **Content Page Switch:** Fires `OnTabSelected(tabId)` to toggle visibility or slide content frames.
