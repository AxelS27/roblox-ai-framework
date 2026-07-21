# UI Component Blueprint: Leaderboard (Custom Leaderstats Board)

> [!NOTE]
> Component for displaying the custom in-game player list, active player stats (leaderstats columns), ranks, and player interaction rows.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type LeaderboardRowData = {
    Rank: number,
    UserId: number,
    DisplayName: string,
    Username: string,
    Stats: { [string]: any }, -- Dynamic stat columns (e.g. Coins, Wins, Stage)
    IsLocalPlayer: boolean,
}

export type LeaderboardProps = {
    HeaderColumns: { string }, -- e.g. { "Level", "Wins", "Coins" }
    PlayersList: { LeaderboardRowData },
    OnPlayerClicked: (userId: number) -> (),
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Leaderboard Outer Board - Size {0, 360, 0, 480})
├── UICorner (CornerRadius: UDim.new(0, 16))
├── UIStroke (Thickness: 2.5px, ApplyStrokeMode: Border, Color: Hex #2a2c3a)
├── UIGradient (Premium dark carbon glassmorphism background gradient)
├── Frame (Header Panel)
│   ├── TextLabel (Board Title, e.g. "PLAYERS")
│   └── Frame (Stat Columns Headers Row)
│       ├── UIListLayout (Horizontal layout)
│       └── TextLabel (Stat Column Names - Level, Wins, etc.)
└── ScrollingFrame (Players List Container)
    ├── UIListLayout (Vertical alignment, padding 6px)
    └── Frame (PlayerRowTemplate - Entry row for each player)
        ├── UICorner (CornerRadius: UDim.new(0, 8))
        ├── UIStroke (Subtle border, glows neon highlight for LocalPlayer)
        ├── ImageLabel (Player Avatar Headshot Thumbnail)
        ├── TextLabel (Player Name & Username)
        └── Frame (Stat Values Grid)
            ├── UIListLayout (Horizontal alignment aligning with headers)
            └── TextLabel (Value labels)
```

---

## 🎨 Visual Aesthetics & "Anti-Polos" Styling

To ensure the custom leaderboard does not look like a plain solid rectangular box, follow these styling criteria:

1. **Header & Local Player Highlighting**:
   - The Local Player's row (`IsLocalPlayer == true`) must stand out visually with a gold or neon purple background gradient and a glowing border stroke (`UIStroke`).
   - Standard rows use a translucent dark-gray backing overlay.

2. **Compact Avatar Integration**:
   - Each player row displays a small circular thumbnail of the player's headshot.
   - Use `GetUserThumbnailAsync` to load thumbnails in real time.

3. **Row Hover & Selection Feedback**:
   - **Hover**: On `MouseEnter`, the player row slides slightly to the right (`Position X +4px` offset) and its border stroke brightens.
   - **Click**: Triggers a click sound effect and opens the detailed **Player Profile Card** popup next to the leaderboard.

---

## 🎭 State Transitions & Animations

| Action / Event | Animation Transition | Easing & Duration | SFX |
| :--- | :--- | :--- | :--- |
| **Open Leaderboard** | Board slides into view from the right edge | `Back Out (0.35s)` | Page Slide sound |
| **Close Leaderboard** | Board slides out to the right edge | `Quad In (0.25s)` | Page Slide sound |
| **Row Hover** | Row expands horizontally and shifts right | `Quad Out (0.12s)` | Hover Tick sound |
| **Player Joined** | New row slides in from bottom of list | `Back Out (0.3s)` | Notification Tick |
