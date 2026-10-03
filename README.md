# Celestial Rivals

Roblox Rivals script project — starting with **CelestialUI**, a dark, rounded, MAVISDMA-style UI library built from modular Luau files. Real Lucide icons, zero emojis.

> Loadstring (executor, one line):
> ```lua
> local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/CelestialUI.lua"))()
> ```
> Tested on executors via `game:HttpGet`. See [Installation](#installation) for Studio setup.

---

## Contents

- [Features](#features)
- [Preview](#preview)
- [Installation](#installation)
  - [Executor (loadstring)](#executor-loadstring)
  - [Studio (ModuleScripts)](#studio-modulescripts)
- [Quick start](#quick-start)
- [Project structure](#project-structure)
- [API reference](#api-reference)
  - [Library](#library)
  - [Window](#window)
  - [Tab](#tab)
  - [Toggle](#toggle)
  - [Slider](#slider)
  - [Range (dual slider)](#range-dual-slider)
  - [Dropdown](#dropdown)
  - [Colorpicker](#colorpicker)
  - [Section / Label / Button](#section--label--button)
- [Theming](#theming)
- [Icons (Lucide)](#icons-lucide)
- [Config save / load](#config-save--load)
- [Behavior notes](#behavior-notes)
- [Rebuilding the single-file bundle](#rebuilding-the-single-file-bundle)
- [Engineering notes](#engineering-notes)
- [Roadmap](#roadmap)
- [License](#license)

---

## Features

- Dark **MAVISDMA / Past Owl** look: sidebar + search + content pages, purple `#9496FF` accent
- **Real Lucide icons** (42 vendored `rbxassetid` assets, no runtime download, no emojis anywhere)
- Controls: toggles, sliders, dual-range sliders, dropdowns, HSV wheel color picker, buttons, sections, labels
- **App settings modal**: Light / Dark / Black themes, accent presets + custom color, interface scale slider (50–150%)
- **Color picker modal**: 150px HSV wheel, H/S/V sliders, hex input, floating RGB tooltip card
- Prefix **search** filters every row by name
- `RightShift` / `Insert` toggles the whole UI; top-bar drag (mouse + touch)
- Config save/load (executor `writefile`, Color3 + range aware)
- Executor-safe parenting: `gethui()` → CoreGui → PlayerGui, duplicate cleanup on re-execute

---

## Preview

Reference layout the library recreates:

- Left: search box, `CELESTIAL RIVALS` wordmark, tabs — Aimbot, Triggerbot, Flickbot, Players, World, Player list, Configs, Miscellaneous
- Content: section headers (`ACCURACY`, `ASSIST`…), rows with toggles / sliders / dropdowns / color dots
- Popups: App settings (theme segmented control, accent dots, language row, scale slider), color wheel picker, RGB tooltip card

Run `Ui lib/Example.lua` to spawn the exact reference demo.

---

## Installation

### Executor (loadstring)

One line, no files needed (single-file bundle, one HTTP request):

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/CelestialUI.lua"))()
```

Direct-`Init.lua` loadstring also works (it fetches siblings over HTTP automatically):

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/Ui%20lib/Init.lua"))()
```

Forks: point the loader at your own repo without editing files:

```lua
getgenv().CelestialUI_Repo = "https://raw.githubusercontent.com/YOU/FORK/main/Ui%20lib/"
```

### Studio (ModuleScripts)

Recommended while editing — one ModuleScript per file, same names:

```text
UiLib (ModuleScript ← paste Ui lib/Init.lua)
├── Theme         ← Ui lib/Theme.lua
├── Utils         ← Ui lib/Utils.lua
├── Icons         ← Ui lib/Icons.lua
├── Config        ← Ui lib/Config.lua
├── Settings      ← Ui lib/Settings.lua
├── ColorPicker   ← Ui lib/ColorPicker.lua
├── Window        ← Ui lib/Window.lua
├── Tab           ← Ui lib/Tab.lua
├── Toggle        ← Ui lib/Toggle.lua
├── Slider        ← Ui lib/Slider.lua
└── Dropdown      ← Ui lib/Dropdown.lua
```

Then:

```lua
local UI = require(path.To.UiLib)
```

> `Example.lua` is a demo script, not a module — paste it into a LocalScript (Studio) or run it after the loadstring (executor).

---

## Quick start

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/CelestialUI.lua"))()

local Win = UI:CreateWindow({
    Title = "CELESTIAL",      -- white half of the wordmark
    AccentTitle = "RIVALS",   -- accent half of the wordmark
    User = "Past Owl",        -- top-right label
    Theme = "Dark",           -- "Dark" | "Light" | "Black"
    Accent = Color3.fromRGB(148, 150, 255),
})

local aim = Win:Tab({ Name = "Aimbot" }) -- icon auto-mapped (crosshair)

aim:Section("ACCURACY")
aim:Dropdown({
    Name = "Recoil control",
    Options = { "Off", "Legit", "Rage" },
    Default = "Legit",
    Callback = function(v) print("recoil:", v) end,
})
aim:Slider({ Name = "FOV size", Min = 0, Max = 30, Default = 10, Decimals = 1 })
aim:Toggle({ Name = "Penetrate walls", Default = true, Callback = print })
aim:Range({ Name = "First bullet delay", Min = 0, Max = 1000, DefaultMin = 200, DefaultMax = 700 })

print(UI.Flags["Penetrate walls"]) --> true
```

---

## Project structure

```text
Celestial-Rivals/
├── CelestialUI.lua          single-file bundle (generated — do not edit)
├── README.md
├── LICENSE
├── build.py                 regenerates the bundle from modules
└── Ui lib/
    ├── Init.lua             entry point, module loader, public Library
    ├── Theme.lua            palettes, radii, fonts, accent presets
    ├── Utils.lua            constructors (corner/stroke/shadow/drag/parenting)
    ├── Icons.lua            vendored Lucide assets + helpers
    ├── Config.lua           save/load (writefile aware)
    ├── Window.lua           window shell (sidebar, search, pages, modals)
    ├── Tab.lua              tabs, rows, sections, labels, buttons
    ├── Toggle.lua           toggle control
    ├── Slider.lua           slider + dual-range control
    ├── Dropdown.lua         dropdown control
    ├── ColorPicker.lua      HSV wheel modal + RGB tooltip
    ├── Example.lua          reference demo (Aimbot page etc.)
    ├── dist/
    │   └── CelestialUI.lua  generated copy of the bundle
    └── legacy/
        └── CelestialUI.legacy.lua  first monolith, superseded
```

Edit modules, never the bundle. The loader order is `Theme → Utils → Icons → Config → Settings → ColorPicker → Tab → Toggle → Slider → Dropdown → Window`.

---

## API reference

### Library

| Member | Description |
|---|---|
| `UI:CreateWindow(opts)` | Creates a window, returns `Window`. See opts below. |
| `UI.Flags` | Live table of every control value, keyed by control `Name`. Toggles → `boolean`, sliders → `number`, ranges → `{a, b}`, dropdowns → `string`, colorpickers → `Color3`. |
| `UI:SaveConfig(name)` | Writes `Flags` to `<name>.json` via `writefile` (Color3/range encoded). Returns `true`, or `false, json` when no filesystem exists. |
| `UI:LoadConfig(name)` | Reads `<name>.json` back into `Flags`. |
| `UI:SetAccent(color)` | Recolors every open window. |
| `UI:UnloadAll()` | Destroys every window. |
| `UI.Icons` | The Icons module (see [Icons](#icons-lucide)). |
| `UI.Utils` | The Utils module (constructors for your own extras). |

`CreateWindow` opts:

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"CELESTIAL"` | White half of the wordmark. |
| `AccentTitle` | string | `"RIVALS"` | Accent half of the wordmark. |
| `User` | string | LocalPlayer name | Top-right user label. |
| `Theme` | string | `"Dark"` | `"Dark"`, `"Light"` or `"Black"`. |
| `Accent` | Color3 | `#9496FF` | Starting accent. |
| `Size` | UDim2 | `860×600` | Base window size (auto-shrinks on small screens). |

### Window

| Method | Description |
|---|---|
| `Win:Tab({Name, Icon?})` | Creates a sidebar tab + page. `Icon` overrides the auto-mapped Lucide icon (any name from the Icons table). |
| `Win:SetTheme("Dark"/"Light"/"Black")` | Rethemes text, rows, cards, strokes and icons live. |
| `Win:SetAccent(color)` | Recolors wordmark, active tab, toggles, sliders, buttons. |
| `Win:SetScale(0.5–1.5)` | Interface scale (same as the App-settings slider). |
| `Win:Toggle(visible?)` | Shows/hides the UI (no arg = flip). |
| `Win:Unload()` | Destroys this window. |
| `Win:Notify(title, sub?)` | Bottom-right toast, auto-dismisses. |
| `Win:OpenColorPicker(default?, callback?, anchor?)` | Opens the wheel picker programmatically. |

### Tab

Tab buttons show a Lucide icon, the name, and a chevron. The first tab activates automatically.

### Toggle

```lua
local t = tab:Toggle({
    Name = "Penetrate walls", -- required, also the Flags key
    Default = true,           -- boolean
    More = false,             -- shows the ellipsis affordance (opens nothing by itself)
    Callback = function(on) print(on) end,
})
t:Set(false) -- silent=false; t:Set(false, true) skips the callback
print(t:Get())
```

26×26 rounded-7 box, accent fill + Lucide check when on. Clicking the box flips it.

### Slider

```lua
local s = tab:Slider({
    Name = "Kill delay",
    Min = 0, Max = 1000, Default = 500,
    Decimals = 0,        -- auto: 1 when (Max-Min) < 20
    Suffix = "ms",       -- appended to the value label
    Callback = function(v) print(v) end,
})
s:Set(750)
```

4px track, accent fill, 14px white knob, value label top-right. Drag with mouse or touch.

### Range (dual slider)

```lua
tab:Range({
    Name = "First bullet delay",
    Min = 0, Max = 1000,
    DefaultMin = 200, DefaultMax = 700,
    Callback = function(a, b) print(a, b) end,
})
```

Two knobs, accent band between them, `200 - 700` readout. Drags the nearer knob.

### Dropdown

```lua
tab:Dropdown({
    Name = "Recoil control",
    Options = { "Off", "Legit", "Rage", "Custom curve" },
    Default = "Legit",
    Callback = function(opt) print(opt) end,
})
```

36px header with Lucide chevron; expands to `N×30px` with a tween; selected option is accent-tinted.

### Colorpicker

```lua
tab:Colorpicker({
    Name = "Accent color",
    Default = Color3.fromRGB(148, 150, 255),
    Callback = function(c) print(c) end,
})
```

Row shows a circular preview. Click opens the wheel modal (H/S/V sliders, hex field, `Set color` button, floating RGB tooltip). Confirming also retints the whole window accent.

### Section / Label / Button

```lua
tab:Section("ACCURACY")          -- small caps header
tab:Label("Helper text")         -- dim 12px line
tab:Button({
    Name = "Save config",
    Callback = function() UI:SaveConfig("celestial_rivals") end,
})
```

---

## Theming

Built-ins: `Dark` (default, `#121216`), `Black` (`#08080A`), `Light`. Switch live from the gear menu or `Win:SetTheme(name)`.

- Accent presets: `#9496FF` (default), deep purple, blue, cyan, mint — plus the rainbow button for a custom wheel color.
- Every accent-driven element (active tab bar, toggles, slider fills, buttons, wordmark) updates through `_AccentUpdaters`.
- Corner radii live in `Theme.Radius` (main 14, modal 12, row 8, toggle 7). Circles use `Scale = 1`.
- Fonts use `GothamMedium/Bold` (auto-maps to Montserrat on live clients — maximum executor compatibility).

---

## Icons (Lucide)

Vendored in `Ui lib/Icons.lua` — real Lucide assets, zero network calls at runtime:

```text
search, crosshair, target, zap, rotate-ccw, users, user, user-round,
globe, list, archive, save, folder, settings, settings-2,
sliders-horizontal, cog, sun, moon, moon-star, check, x, plus, minus,
chevron-down, chevron-up, chevron-right, ellipsis, ellipsis-vertical,
info, copy, palette, languages, eye, eye-off, gauge, trash-2,
download, upload, scaling, circle-dot, log-out, power
```

Helpers:

```lua
UI.Icons.New("search", 16, Theme.TextDim, { Parent = box }) -- ImageLabel
UI.Icons.Button("x", 14, color, { Parent = modal })        -- ImageButton
UI.Icons.Apply(existing, "check", Color3.fromRGB(255,255,255))
UI.Icons.Add("my-icon", "rbxassetid://123456")             -- extend
UI.Icons.Preload()                                         -- preload all 42
```

Icons that must follow themes get `SetAttribute("IRole", "Dim"|"Dark"|"Primary")`; `Window:SetTheme` recolors them automatically. `"Active"` is reserved for force-white icons (active tab, selected pills).

---

## Config save / load

```lua
UI:SaveConfig("celestial_rivals") -- → celestial_rivals.json (executor)
UI:LoadConfig("celestial_rivals")
```

- Color3 values serialize as hex, ranges as `{a, b}` pairs — full round-trip fidelity.
- Without a filesystem (`writefile` missing), `SaveConfig` returns `false, json` so you can store it yourself; `Config.LoadJSON(flags, json)` restores it.

---

## Behavior notes

- **Search**: the sidebar box filters every control row by name across all tabs.
- **Toggle UI**: `RightShift` or `Insert`. No game input is consumed (`gpe` respected).
- **Drag**: top 28px bar; native `UIDragDetector` when present, Lua mouse+touch fallback otherwise.
- **Scaling**: centered `AnchorPoint (0.5, 0.5)` window + `UIScale`; auto-fits viewports below ~1000×700; App-settings slider multiplies 50–150%.
- **Parenting**: `gethui()` → CoreGui (capability-checked) → PlayerGui; re-executing destroys the previous `CelestialRivals` gui. `ZIndexBehavior = Sibling`, `DisplayOrder = 999`.
- **Modals**: settings, color picker and toasts live inside `Main` at `ZIndex 40+` so they scale and toggle with the window.
- **Performance**: hairline `UIStroke`s (thickness 1, never tweened), native `UIShadow` wrapped in `pcall`, no per-frame gradient rebuilds, wheel sampling only while dragging.

---

## Rebuilding the single-file bundle

`CelestialUI.lua` (repo root + `Ui lib/dist/`) is generated — never edit it by hand:

```sh
python build.py
```

It inlines the 11 modules in dependency order, verifies every `need()` resolves, and prints size stats. Commit the regenerated bundle with your changes.

---

## Engineering notes

Researched against Roblox Creator docs + DevForum (2024–2026):

- `UICorner` uses **Offset** everywhere (Scale distorts and pills); `Scale = 1` only for perfect circles (knobs, dots, avatar, wheel).
- Borders are `UIStroke` (`LineJoinMode.Round`, `ApplyStrokeMode.Border`, ~0.93 transparency), never `BorderColor3`.
- Native `UIShadow` (2026) replaces 9-slice shadows; `pcall`-guarded for old clients.
- No `CanvasGroup` clipping (goes blurry/black on low-memory devices) — rows clip themselves instead; `UICorner` is never placed on a `ScrollingFrame`.
- Wheel math is the standard HSV cylinder: `H = (π − atan2(dY,dX)) / 2π`, `S = dist/radius`, `V` from slider.

---

## Roadmap

- [x] Modular UI library matching the reference
- [ ] Rivals aimbot tab wiring (FOV, smoothing, hitbox)
- [ ] Triggerbot + flickbot logic
- [ ] Player list + ESP bindings
- [ ] Config profiles UI (multiple slots, auto-load)

---

## License

MIT — see [LICENSE](LICENSE).
