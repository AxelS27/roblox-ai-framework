# UI Design System & Tokens

---

## 🎨 Global Palette Colors (HSL / Hex)
* **Primary Color (Buttons/Titles):** `[Hex #00aaff / HSL(200, 100%, 50%) - Sky Blue]`
* **Secondary Color (Borders/Accents):** `[Hex #ff007f / HSL(330, 100%, 50%) - Pink Accent]`
* **Background Color (Panels/Fills):** `[Hex #1e1e1e / HSL(0, 0%, 12%) - Charcoal Glassmorphism]`
* **Warning/Alert Color:** `[Hex #ffaa00 - Amber Warning]`

---

## ✒️ Typography & Fonts
* **Title Font:** `[Fredoka One / Gotham Bold]`
* **Body Font:** `[Source Sans Pro / Inter]`

---

## 🎬 Tween Animations (Easing Standards)
* **Open Screen Tween:** `[EasingStyle: Quad, EasingDirection: Out, Time: 0.3s - Fade and Zoom]`
* **Button Hover Tween:** `[EasingStyle: Sine, EasingDirection: Out, Time: 0.15s - Scale 1.05x]`
* **Dynamic Camera Tween:** `[EasingStyle: Quad, EasingDirection: InOut, Time: 0.4s - Seamless focus slide]`

---

## 📐 Responsive Design Guidelines
1. **Scale Over Offset**: Position and Size properties must use Scale (`{X.scale, 0, Y.scale, 0}`) for responsive layout.
2. **Aspect Ratio Constraints**: Keep buttons and square elements proportional using `UIAspectRatioConstraint`.
3. **Safe Area Insets**: Keep HUD elements padded away from mobile notches and topbar insets.
