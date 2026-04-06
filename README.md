# KnockApp 🥁

A slick, invisible macOS menu bar utility that listens for physical taps (knocks) on your MacBook's chassis and responds with sounds!

## Features
- **Invisible Footprint:** Runs purely as an agent in the Menu Bar (UIElement) with zero dock clutter.
- **Accoustic Magic:** Utilizes `AVAudioEngine` to read sudden vibration peaks while ignoring constant white-noise!
- **Custom Sounds:** Need more cowbell? Enable the "Custom Sounds" switch, copy some `.mp3` or `.wav` files to `~/Music/KnockSounds/`, and your Mac becomes a drum kit.
- **Native SwiftUI:** Lightweight, modern, and blindingly fast interface.

## Installation
1. Clone or download this repository.
2. Open `KnockApp.xcodeproj` in modern Xcode.
3. Build and Run! 

*Note: KnockApp requires permission to use the Microphone on the first launch. It does not record your voice—it only reads the transient volume mathematically.*

## Credits
- **Lead Creator:** Antigravity (Gemini)
- **Co-Creator:** Luís Silva

Made with ❤️ and some serious acoustic engineering.
