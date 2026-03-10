# 🧩 Unicro - Micro UX Library

<div align="center">
  <img src="https://img.shields.io/badge/platform-iOS-blue" alt="Platform iOS | macOS">
  <img src="https://img.shields.io/badge/Swift-15+-orange" alt="Swift 15+">
<!--  <img src="https://img.shields.io/badge/license-MIT-brightgreen" alt="MIT License">-->
</div>

<p align="center">A lightweight, modular component library for crafting fluid, animated, and state-aware SwiftUI experiences with minimal effort.</p>
<p align="center">
  <img src="Assets/unicro_herovideo.gif" alt="Unicro Library Demo" width="600">
</p>

## ✨ Overview

**Unicro** provides a growing collection of interaction patterns and visual states that help you create polished user experiences without complex custom implementations. Built entirely with SwiftUI, it's designed to be easy to integrate and customize for any project.

The library is structured into two internal toolkits:

- **FluidKit**: Gesture-driven layouts with smooth animations
- **StateKit**: Loading patterns and transition states

All components are accessible via a simple `import Unicro`.

## 📦 Installation

### Swift Package Manager

Add Unicro to your project by adding it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/laiweiii/Unicro.git", from: "1.0.0")
]

