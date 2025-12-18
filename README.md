# Stretchable

<img src="https://github.com/Livsy90/Stretchable/blob/main/demo.gif">

A lightweight SwiftUI helper that adds a **stretch / overscroll scaling effect** to any view inside a `ScrollView`, similar to the native iOS 17 `visualEffect` behavior — with a **safe backport to iOS 16**.

The API is designed to be minimal, expressive, and consistent across iOS versions.

---

## Features

- ✅ Works on **iOS 13+**
- ✅ Supports **vertical and horizontal** `ScrollView`
- ✅ Optional **uniform scaling** (both axes) or axis-only stretching
- ✅ Single, unified modifier API
- ✅ No custom containers
- ✅ Pure SwiftUI

---

In Xcode:

Open your project

Go to File → Add Packages…

Enter the package URL:
```
https://github.com/Livsy90/Stretchable.git
```

Add the package to your target

Once added, import the module where needed:

```
import Stretchable
```

The `stretchable(axis:uniform:)` modifier will then be available on all View types.

---

## Demo

Typical use cases:
- Stretchy headers
- Pull-to-expand hero views
- Overscroll visual feedback
- Horizontal carousels with elastic leading edge

```swift
ScrollView {
    header
        .stretchable(axis: .vertical, uniform: true)
}
```

---

## API

```swift
extension View {
    func stretchable(
        axis: Axis = .vertical,
        uniform: Bool = false
    ) -> some View
}
```

### Parameters

| Parameter | Description |
|---------|-------------|
| `axis` | `.vertical` for vertical `ScrollView`, `.horizontal` for horizontal |
| `uniform` | If `true`, scales both axes. If `false`, scales only along `axis` |

---

## Usage Examples

### Vertical ScrollView (Stretchy Header)

```swift
ScrollView {
    VStack {
        header
            .frame(height: 150)
            .stretchable(axis: .vertical, uniform: true)

        content
    }
}
```

### Horizontal ScrollView

```swift
ScrollView(.horizontal) {
    HStack {
        header
            .frame(height: 150)
            .stretchable(axis: .horizontal, uniform: true)

        items
    }
}
```

---

## How It Works

### iOS 17+

On iOS 17 and newer, the modifier uses:

- `visualEffect`
- `GeometryProxy.frame(in: .scrollView)`

This provides accurate overscroll detection relative to the scroll container and ensures native-quality behavior.

### Older iOS versions Backport

Since `.visualEffect` and `.scrollView` coordinate space are unavailable on older versions, the backport uses:

- `GeometryReader`
- `PreferenceKey`

This approach approximates scroll-relative overscroll while remaining safe and performant on older iOS versions.

---

## Design Notes

- Stretching activates **only when pulling past the start edge** (top / leading).
- Normal scrolling does **not** trigger scaling.
- Anchors are chosen to match the scroll direction:
  - `.bottom` for vertical
  - `.trailing` for horizontal

---

## Requirements

- iOS 13.0+

---

## License

MIT
