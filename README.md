# Arcade Mini Games 

A sleek, fast-paced iOS arcade suite built entirely with SwiftUI and Swift. The application provides multiple modular mini-games featuring smooth, tactile interactions, personal high-score tracking, and a gorgeous glassmorphic dark theme interface.

---

## Architecture Overview

The project is engineered using a decoupled, highly modular **MVVM (Model-View-ViewModel)** architecture paired with a centralized repository pattern for state persistence.

### Key Architectural Layers:
* **View Layer (SwiftUI):** Declarative, layout-driven UI components. Features structural optimizations like generic `GameCardLink` wrappers to reduce template overhead and custom `ButtonStyle` classes to handle responsive spring animations dynamically.
* **ViewModel Layer (Combine / ObservedObjects):** Bridges game mechanics and user settings. Employs shared view models (e.g., `StatsViewModel`) to aggregate live game metrics without locking the main thread.
* **Model & Persistence Layer:** Employs an explicit `GameMode` enumeration to securely route and scope persistent game events. Data flows continuously down to a custom `GameSessionStore` infrastructure to capture local personal best metrics.

---

## Features List

* **Dynamic Mini-Game Suite:**
  * **Tap Frenzy:** A pure reflex test built around intense tap frequencies.
  * **Light It Up:** A spatial pattern recognition matrix utilizing fading grids.
  * **Quiz Rush:** A rapid-fire trivia engine tracking dynamic combo streaks.
* **Real-Time High Score Tracking:** Automatic score indexing powered by a custom context-aware `HighScoreBubble` component that conditionally previews personal best achievements on the dashboard.
* **Modern Premium UI:** Built on a unified `AppTheme` specifying neon linear gradients over a low-contrast dark glassmorphic framework.
* **Tactile Feedback:** Handcrafted button mechanics scaling the UI framework smoothly ($0.97\times$) on user press with custom spring physics.

---

## Known Limitations

* **Local Storage Bounds:** High-score mechanics rely strictly on local state persistence (`GameSessionStore`); uninstalling or offloading the application resets historical bests.
* **Static Game Assets:** The current configuration structure utilizes hardcoded local properties (`Games` enum), limiting the ability to inject cloud-hosted assets dynamically.
* **Monolithic Destination Binding:** Layout components leverage concrete structural types within destination injection routines instead of deep-linked routing patterns, posing minor layout coupling risks if scaling to dozens of modules.

---

## Reflection

Developing this arcade framework highlighted the immense strengths of SwiftUI's declarative syntax, while emphasizing the importance of keeping views dumb and lightweight. 

Early iterations coupled game identifiers directly within layout code, making high-score filtering highly redundant. Refactoring the implementation to link an explicit `GameMode` parameter to a modular view model simplified data fetching dramatically. The resulting architecture keeps view models easily testable in isolation, ensures high performance even with multiple concurrent UI bindings, and provides a clear blueprint for adding future mini-game modules effortlessly.
