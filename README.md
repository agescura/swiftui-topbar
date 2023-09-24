
swiftui-topbar is a library for building an iOS top bar view for SwiftUI.

![Xcode 15.0+](https://img.shields.io/badge/Xcode-15.0%2B-blue.svg)
![iOS 14.0+](https://img.shields.io/badge/iOS-14.0%2B-blue.svg)
![Swift 5.8+](https://img.shields.io/badge/Swift-5.8%2B-orange.svg)

## Installation

Add the following to your `Package.swift`:

```swift
.package(url: "https://github.com/agescura/swiftui-topbar", ....),
```

Next, add `Hero` to your App targets dependencies like so:

```swift
.target(
    name: "App",
    dependencies: [
        "TopBar",
    ]
),
```

## Usage

```swift
TopBarView(
	data: Tab.allCases,
	selected: self.$selected,
	header: { tab in
		Text(tab.rawValue)
	}
)
```

## Nexts steps

- Styling
- Accesibility
- Add case studies
