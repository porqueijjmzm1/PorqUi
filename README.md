# UILib 1.1.0 — Documentation

A single-file UI library for Roblox. It includes a tabbed window, toggles, sliders, dropdowns, buttons, notifications, themes, mobile support (floating ball) and a 3D viewport (with a ready-made ESP preview).

## Table of contents

1. [Loading the library](#1-loading-the-library)
2. [Quick start](#2-quick-start)
3. [Library](#3-library)
4. [Window](#4-window)
5. [Tabs and elements](#5-tabs-and-elements)
6. [Flags](#6-flags)
7. [Notifications](#7-notifications)
8. [Themes](#8-themes)
9. [Icons](#9-icons)
10. [Mobile support](#10-mobile-support)
11. [3D parts in the UI (Viewport)](#11-3d-parts-in-the-ui-viewport)
12. [ESP Preview](#12-esp-preview)
13. [Tips and notes](#13-tips-and-notes)

---

## 1. Loading the library

Host `UILib.lua` somewhere that serves raw text (GitHub raw, for example) and load it with `loadstring`:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/UILib.lua"))()
```

The script ends with `return Library`, so the value returned by `loadstring` is the library itself.

> The library mounts its GUI using `gethui()` when available, then `CoreGui`, and finally `PlayerGui`. If you run your script again, the old window with the same `Name` is removed automatically.

---

## 2. Quick start

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = Library:CreateWindow({
    Name = "My Hub",
    Subtitle = "v1.0",
    Theme = "Dark",
    Size = UDim2.fromOffset(600, 400),
    ToggleKey = Enum.KeyCode.RightShift,
})

local Main = Window:CreateTab("Main", "settings")

Main:CreateSection("General")

Main:CreateToggle({
    Name = "Enable feature",
    CurrentValue = false,
    Flag = "Feature",
    Callback = function(value)
        print("Feature:", value)
    end,
})

Main:CreateSlider({
    Name = "Value",
    Range = { 0, 100 },
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "Value",
    Callback = function(value)
        print("Value:", value)
    end,
})

Main:CreateButton({
    Name = "Say hello",
    Callback = function()
        Window:Notify({ Title = "Hello!", Content = "Button clicked.", Type = "Success" })
    end,
})
```

---

## 3. Library

| Member | Description |
|---|---|
| `Library:CreateWindow(cfg)` | Creates the window. Returns a `Window`. |
| `Library:SetTheme(name)` | Changes the current theme. Returns `true`/`false`. |
| `Library:RegisterTheme(name, colors)` | Registers a new theme (see [Themes](#8-themes)). |
| `Library:SetFont(regular, medium, bold)` | Changes the fonts (`Enum.Font`). |
| `Library:AddIcon(name, assetId)` | Registers a named icon (see [Icons](#9-icons)). |
| `Library.CreateDummy(colors?)` | Creates a simple 3D dummy (`Model`) to use in viewports. |
| `Library.Icons` | Table of registered icons. |
| `Library.Logo` | Window logo asset (default: `rbxassetid://76951800690268`). |
| `Library.MobileIcon` | Mobile ball asset (default: `rbxassetid://12519968991`). |
| `Library.Version` | Library version. |
| `Library.Theme`, `Library.Util`, `Library.Loader` | Internal modules (advanced use). |

### `CreateWindow(cfg)`

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | string | `"UI Library"` | Window title. Also used as the `ScreenGui` name. |
| `Subtitle` | string | none | Small text next to the title. |
| `Theme` | string | `"Dark"` | Initial theme. |
| `Size` | UDim2 | `580x390` | Window size. Automatically reduced on small screens. |
| `ToggleKey` | Enum.KeyCode | `RightShift` | Key that shows/hides the window (desktop). |
| `Logo` | string/number | `Library.Logo` | Logo image in the top bar. |
| `MobileIcon` | string/number | `Library.MobileIcon` | Image for the floating ball. |
| `MobileButton` | boolean | automatic | `true` forces the ball (e.g. to test on desktop), `false` disables it. Automatic = touch devices only. |
| `MobileButtonSize` | number | `46` | Ball diameter in pixels. |

---

## 4. Window

| Member | Description |
|---|---|
| `Window:CreateTab(name, icon?)` | Creates a tab. `icon` is a registered name, an ID or an `rbxassetid://`. |
| `Window:SetVisible(bool)` | Shows or hides the window. |
| `Window:Minimize(bool)` | Minimizes or restores. |
| `Window:SetTheme(name)` | Changes the theme. |
| `Window:Notify(opts)` | Shows a notification (see [Notifications](#7-notifications)). |
| `Window:Task(title, fn)` | Shows a loading notification, runs `fn`, and turns into success or error when it ends. |
| `Window:SetMobileButtonVisible(bool)` | Shows or hides the mobile ball (if it exists). |
| `Window:Destroy()` | Removes the window and the ball, and disconnects everything. |
| `Window.Flags` | Table with the elements that have a `Flag` (see [Flags](#6-flags)). |
| `Window.Visible`, `Window.Minimized` | Current state. |
| `Window.Main`, `Window.Gui` | The main `Frame` and the `ScreenGui` instances. |

```lua
Window:Task("Loading resources", function()
    task.wait(3)          -- if this errors, the notification turns into "Error"
end)
```

---

## 5. Tabs and elements

All methods below are called on a `Tab` (the return value of `Window:CreateTab`).

### `Tab:CreateSection(name)`
Small heading to separate groups. Returns `{ Set = function(_, text) }`.

### `Tab:CreateLabel(text)`
Simple line of text. Returns an object with `:Set(text)`.

### `Tab:CreateParagraph({ Title, Content })`
Card with a title and multi-line text. Returns an object with `:Set(title, content)`.

### `Tab:CreateButton(opts)`

| Field | Description |
|---|---|
| `Name` | Button text. |
| `Icon` | Icon on the left. Default `"click"`; use `false` to remove it. |
| `Callback` | Function called on click. |

### `Tab:CreateToggle(opts)`

| Field | Description |
|---|---|
| `Name` | Text. |
| `CurrentValue` | Initial value (`true`/`false`). |
| `Flag` | Name used to register it in `Window.Flags`. |
| `Callback(value)` | Called when the value changes. |
| `Icon` | Fixed icon. |
| `IconOn` / `IconOff` | Different icons for on and off (e.g. `"eye"` and `"eyeclosed"`). |

Returns `{ Value, Set(value) }`. `:Set()` also fires the `Callback`.

### `Tab:CreateSlider(opts)`

| Field | Description |
|---|---|
| `Name` | Text. |
| `Range` | `{ min, max }`. |
| `Increment` | Step (e.g. `1`, `0.05`). The number of decimals is derived from the step. |
| `Suffix` | Text after the number (`"°"`, `" studs"`). |
| `CurrentValue` | Initial value. |
| `Flag` | Name used to register it in `Window.Flags`. |
| `Callback(value)` | Called when the value changes. |

Returns `{ Value, Set(value) }`.

### `Tab:CreateDropdown(opts)`

| Field | Description |
|---|---|
| `Name` | Text. |
| `Options` | List of strings. |
| `CurrentOption` | Initial option (default: the first one). |
| `Flag` | Name used to register it in `Window.Flags`. |
| `Callback(option)` | Called when an option is picked. |
| `Icon` | Default `"dots"`; use `false` to remove it. |

Returns `{ Value, Open, Set(option), Refresh(newOptions, keepCurrent?) }`.

```lua
local dd = Tab:CreateDropdown({ Name = "Player", Options = { "A", "B" }, CurrentOption = "A" })
dd:Refresh({ "X", "Y", "Z" })         -- replaces the options
dd:Refresh({ "X", "Y" }, true)        -- replaces and keeps the selection if it still exists
```

### `Tab:CreateLoader({ Name })`
Card with a spinner. Returns `{ SetText(text), Finish(text?), Destroy() }`.

```lua
local loader = Tab:CreateLoader({ Name = "Processing..." })
task.delay(3, function() loader:Finish("Done") end)
```

### `Tab:CreateViewport(opts)` and `Tab:CreateEspPreview(opts)`
See sections [11](#11-3d-parts-in-the-ui-viewport) and [12](#12-esp-preview).

---

## 6. Flags

Any toggle, slider or dropdown created with `Flag = "Name"` is available in `Window.Flags`:

```lua
Main:CreateToggle({ Name = "Speed", Flag = "SpeedOn" })

-- anywhere in your code:
if Window.Flags.SpeedOn and Window.Flags.SpeedOn.Value then
    -- on
end

Window.Flags.SpeedOn:Set(true)   -- change it from code (fires the Callback)
```

Use unique names. If two elements use the same flag, the last one created wins.

---

## 7. Notifications

```lua
local toast = Window:Notify({
    Title = "Title",
    Content = "Message",
    Type = "Success",     -- "Success" | "Error" | "Warning" | "Info" (default)
    Duration = 4,         -- seconds (default 4)
    Icon = "★",           -- optional: text/emoji inside the circle
})
```

The returned handle has:

- `toast:Dismiss()` closes the notification.
- `toast:Update(opts)` changes the title, content, type and duration.

For a loading notification that you control yourself:

```lua
local toast = Window.Notifications:Loading({ Title = "Connecting", Content = "Please wait..." })
task.wait(2)
toast:Update({ Type = "Success", Title = "Connected", Content = "Ready!", Duration = 3 })
```

Tapping a notification also closes it.

---

## 8. Themes

Built-in themes: `Dark`, `Light`, `Ocean`.

```lua
Library:SetTheme("Ocean")
```

To create a theme, pass only the colors that change; the rest comes from `Dark`:

```lua
Library:RegisterTheme("Sunset", {
    Background   = Color3.fromRGB(28, 18, 24),
    Topbar       = Color3.fromRGB(36, 22, 30),
    Element      = Color3.fromRGB(46, 28, 38),
    ElementHover = Color3.fromRGB(62, 38, 50),
    Stroke       = Color3.fromRGB(90, 52, 68),
    Text         = Color3.fromRGB(240, 240, 245),
    SubText      = Color3.fromRGB(160, 160, 175),
    Accent       = Color3.fromRGB(255, 94, 98),
    AccentAlt    = Color3.fromRGB(255, 195, 113),
    Transparency = 0.06,
})
Library:SetTheme("Sunset")
```

`Accent` and `AccentAlt` form the gradient used by toggles, sliders and the active tab.

---

## 9. Icons

Icons can be used in tabs (`CreateTab`), buttons, toggles and dropdowns. They accept:

- a registered name: `"eye"`, `"eyeclosed"`, `"aim"`, `"settings"`, `"click"`, `"dots"`;
- an `"rbxassetid://ID"`;
- a number or numeric string (`"12345"`).

```lua
Library:AddIcon("home", 1234567890)
Window:CreateTab("Home", "home")
```

Creator Store IDs are often **Decals**. The library tries to read the real texture with `game:GetObjects`. If an icon shows up blank, use the **Image** ID (not the Decal ID).

If the icon passed to `CreateTab` is not recognized (for example `"★"`), it is shown as text before the tab name.

---

## 10. Mobile support

On touch devices the library creates a **small floating ball**:

- tapping the ball shows/hides the UI;
- dragging the ball moves it (it stays inside the screen);
- the icon comes from `cfg.MobileIcon` or `Library.MobileIcon`.

The window also adapts to small screens (maximum size = screen minus a margin, and the sidebar gets narrower), and sliders and window dragging work with touch.

```lua
local Window = Library:CreateWindow({
    Name = "My Hub",
    MobileButton = true,                      -- forces the ball on desktop too
    MobileIcon = "rbxassetid://12519968991",
    MobileButtonSize = 50,
})

Window:SetMobileButtonVisible(false)          -- hide the ball later
```

---

## 11. 3D parts in the UI (Viewport)

`Tab:CreateViewport(opts)` puts a `ViewportFrame` inside a card. The model spins on its own and the player can drag to rotate it.

| Field | Default | Description |
|---|---|---|
| `Name` | none | Small title in the corner of the card. |
| `Height` | `200` | Card height in pixels. |
| `Model` | none | Initial `Model` (you can also use `:SetModel`). |
| `Rotate` | `true` | Rotates automatically. |
| `RotateSpeed` | `0.8` | Rotation speed (radians per second). |
| `FieldOfView` | `40` | Viewport camera FOV. |

The returned object (`viewport`) has:

| Member | Description |
|---|---|
| `viewport:SetModel(model)` | Replaces the model and reframes the camera. The previous model is destroyed. |
| `viewport:Add(instance)` | Adds an extra 3D instance (it does not rotate with the model). |
| `viewport:OnRender(fn)` | Registers `fn(dt, viewport)`, called every frame while the card is visible. |
| `viewport:Project(worldPos)` | Converts a 3D position into pixels inside the card (`Vector2`, or `nil` if it is behind the camera). Useful for drawing 2D UI over the 3D view. |
| `viewport.AutoRotate`, `viewport.RotateSpeed`, `viewport.Angle` | Rotation control. |
| `viewport.Model`, `viewport.Camera`, `viewport.Viewport`, `viewport.Card` | Instances. |
| `viewport.Center`, `viewport.Size` | Center and size (bounding box) of the model. |

### Example

```lua
local Tab3D = Window:CreateTab("3D", "settings")

local model = Instance.new("Model")
local ball = Instance.new("Part")
ball.Shape = Enum.PartType.Ball
ball.Size = Vector3.new(3, 3, 3)
ball.Color = Color3.fromRGB(110, 90, 255)
ball.Material = Enum.Material.SmoothPlastic
ball.Anchored = true
ball.Parent = model

local view = Tab3D:CreateViewport({ Name = "Drag to rotate", Height = 200, Model = model })

Tab3D:CreateToggle({
    Name = "Auto rotate",
    CurrentValue = true,
    Callback = function(v) view.AutoRotate = v end,
})
```

Notes:

- Parts must be `Anchored`.
- Models live inside the `ViewportFrame` (a local copy); they do not appear in the game world.
- The viewport camera faces the front of the model (the front is the `-Z` axis, like Roblox characters).

### `Library.CreateDummy(colors?)`

Creates a simple R6-style dummy made of Parts, with `Head`, `Torso`, `Left Arm`, `Right Arm`, `Left Leg` and `Right Leg`.

```lua
local dummy = Library.CreateDummy({
    Skin  = Color3.fromRGB(240, 190, 150),
    Shirt = Color3.fromRGB(70, 110, 200),
    Pants = Color3.fromRGB(55, 58, 70),
})
view:SetModel(dummy)
```

---

## 12. ESP Preview

`Tab:CreateEspPreview(opts)` shows a spinning 3D dummy with ESP elements drawn on top (box, name, health, distance, tracer and skeleton). It is only a **visual preview**: it does nothing in the game.

Options: `Name` (default `"ESP Preview"`), `Height` (default `250`) and `Model` (default: `Library.CreateDummy()`). It returns the same object as `CreateViewport`.

The preview reads these window **flags** every frame. Create the controls with these names and the preview reacts instantly:

| Flag | Type | Effect |
|---|---|---|
| `EspEnabled` | toggle | Turns the whole preview on/off. (If the flag does not exist, it stays on.) |
| `EspBoxes` | toggle | Shows the box. |
| `EspBoxStyle` | dropdown | `"Full"`, `"Corners"` or `"3D"`. |
| `EspNames` | toggle | Shows the name. |
| `EspHealth` | toggle | Health bar (sample value that oscillates). |
| `EspDistance` | toggle | Distance (sample value). |
| `EspTracers` | toggle | Line from the origin point to the dummy. |
| `EspTracerOrigin` | dropdown | `"Bottom"`, `"Middle"` or `"Mouse"`. |
| `EspSkeleton` | toggle | Skeleton (needs the default dummy or a model with the R6 part names). |
| `EspColor` | dropdown | `"Red"`, `"Green"`, `"Blue"`, `"White"` or `"Rainbow"`. |
| `EspAlpha` | slider 0 to 1 | Transparency of the elements. |

### Full example

```lua
local Esp = Window:CreateTab("ESP", "eye")

Esp:CreateSection("Preview")
Esp:CreateEspPreview({ Height = 250 })

Esp:CreateSection("Elements")
Esp:CreateToggle({ Name = "ESP",        Flag = "EspEnabled",  CurrentValue = true })
Esp:CreateToggle({ Name = "Boxes",      Flag = "EspBoxes",    CurrentValue = true })
Esp:CreateToggle({ Name = "Names",      Flag = "EspNames",    CurrentValue = true })
Esp:CreateToggle({ Name = "Health bar", Flag = "EspHealth",   CurrentValue = true })
Esp:CreateToggle({ Name = "Distance",   Flag = "EspDistance" })
Esp:CreateToggle({ Name = "Tracers",    Flag = "EspTracers" })
Esp:CreateToggle({ Name = "Skeleton",   Flag = "EspSkeleton" })

Esp:CreateSection("Style")
Esp:CreateDropdown({ Name = "Box style", Flag = "EspBoxStyle",
    Options = { "Full", "Corners", "3D" }, CurrentOption = "Corners" })
Esp:CreateDropdown({ Name = "Color", Flag = "EspColor",
    Options = { "Red", "Green", "Blue", "White", "Rainbow" }, CurrentOption = "Red" })
Esp:CreateDropdown({ Name = "Tracer origin", Flag = "EspTracerOrigin",
    Options = { "Bottom", "Middle", "Mouse" }, CurrentOption = "Bottom" })
Esp:CreateSlider({ Name = "Transparency", Flag = "EspAlpha",
    Range = { 0, 1 }, Increment = 0.05, CurrentValue = 0.2 })
```

---

## 13. Tips and notes

- **One file, one `return`:** the script returns the `Library`. If you paste its contents inside another script, store the return value in a variable.
- **Window name:** use a unique `Name`. Running again with the same name removes the old window.
- **Protected callbacks:** errors inside a `Callback` are caught and shown as a `warn`, without breaking the UI.
- **Icon yielding:** the first use of an icon by ID may call `game:GetObjects` (network). This is done without blocking the logo and the ball, but tab and card icons may wait a moment when they are created.
- **Cleanup:** call `Window:Destroy()` when unloading your script; it disconnects all of the library's events.
- **Desktop key:** `ToggleKey` does not fire while the player is typing in a Roblox text box.
