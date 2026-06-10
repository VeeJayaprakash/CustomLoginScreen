# Stretchy Login Screen — SwiftUI

A login screen built in pure SwiftUI, featuring a stretchy image that responds fluidly to scrolling, rubber-band panning, and keyboard presentation — with **zero keyboard observers, zero PreferenceKeys, and zero manual offset math**.

## Demo

https://github.com/user-attachments/assets/c75867f7-fed0-4d08-8388-0c15fae95e26

## Behavior

| Interaction | Result |
|---|---|
| At rest | Image fills all space above the form; form is anchored to the bottom edge |
| Pull down | Image stretches from the top (rubber band) |
| Pan up | Image compresses while pinned to the top, then springs back |
| Keyboard appears | Image shrinks to make room; the focused field stays visible above the keyboard |
| Tap outside a field | Keyboard dismisses; image grows back smoothly |

## Features

- Hero image with stretch-on-pull and compress-on-scroll, pinned to the top edge
- Form section anchored to the bottom with no hardcoded height constants
- Email and password fields with focus-aware underlines
- Forgot password action
- Keyboard handling driven entirely by layout — no `NotificationCenter` observers

## How It Works

### 1. One formula drives the stretch and compression

The hero image reads its own position in the scroll view's coordinate space (`minY`) and derives both its height and offset from it:

```swift
let minY = geo.frame(in: .scrollView).minY

Image(.loginScreen)
    .resizable()
    .scaledToFill()
    .frame(width: geo.size.width, height: max(minHeight, slotHeight + minY))
    .clipped()
    .offset(y: -minY) // pin the top edge to the screen top
```

- `minY > 0` (pull down) → height grows → image stretches downward
- `minY < 0` (pan up) → height shrinks → `scaledToFill` re-crops, image compresses
- `offset(y: -minY)` keeps the top edge pinned in both directions

### 2. Bottom anchoring without measuring anything

The scroll content is pinned to exactly the visible height. The form takes its natural size; the image absorbs everything else:

```swift
VStack(spacing: 0) {
    StretchyHeader(minHeight: 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // absorbs remaining space

    formSection // natural height — no hardcoded constants
}
.frame(height: contentHeight) // content == visible area, form bottom == screen bottom
```

### 3. The keyboard is a layout event, not a scroll event

The outer `GeometryReader` does **not** ignore the keyboard safe area. When the keyboard appears, `geo.size.height` shrinks by the keyboard height, which flows through `contentHeight` into the layout — the image compresses automatically, animated with the system keyboard curve:

```swift
GeometryReader { geo in
    let contentHeight = geo.size.height + geo.safeAreaInsets.top
    // keyboard up -> geo.size.height shrinks -> image shrinks. No observers.
}
```

Because nothing scrolls when the keyboard appears, there is no scroll offset to reset or fight — the class of bugs that plagues offset-driven implementations simply does not exist here.

### 4. Scroll bounce with perfectly fitting content

The content fits the screen exactly, so scrolling would normally be disabled. One modifier enables the rubber-band pan:

```swift
.scrollBounceBehavior(.always, axes: .vertical)
```

### 5. Keyboard dismissal

Scroll-driven dismissal (`.interactively`) continuously mutates the keyboard inset mid-drag, which fights the layout resize and feels janky on device. Tap-to-dismiss is decoupled and clean:

```swift
.scrollDismissesKeyboard(.never)
.onTapGesture { focusedField = nil }
```

## Requirements

- iOS 17.0+ (`.scrollView` coordinate space, `.scrollBounceBehavior`)
- Xcode 15+
- Swift 5.9+

For iOS 16 support, replace `geo.frame(in: .scrollView)` with a named coordinate space (`.coordinateSpace(name:)` + `geo.frame(in: .named(...))`).

## Usage

1. Add `LoginView.swift` to your project
2. Add a hero image to your asset catalog and update the `Image(...)` reference
3. Replace the placeholder logo with your brand asset
4. Update the title, fields, and actions for your product
5. Tune `minImageHeight` if you want a different compression floor

## Key Takeaways

- Derive layout from a single source of truth instead of synchronizing multiple state values
- Prefer layout-driven keyboard handling over `NotificationCenter` keyboard observers
- `scaledToFill` + `clipped` + a height change is all an image "shrink" effect needs
- When content fits the screen exactly, `.scrollBounceBehavior(.always)` is the one-line answer to enabling pan gestures
