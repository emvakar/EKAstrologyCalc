# 🌙 EKAstrologyCalc

📅 Astrology Calculator for Moon Phases, Zodiac Signs & More  
🛠 Swift-based astronomical calculations for iOS, macOS & tvOS  

![Swift Version](https://img.shields.io/badge/Swift-6.0-green.svg)
![GitHub stars](https://img.shields.io/github/stars/emvakar/EKAstrologyCalc?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/emvakar/EKAstrologyCalc?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/emvakar/EKAstrologyCalc?style=flat-square)

---

## 🌟 Features
✅ Calculates **moon rise/set times**  
✅ Determines **moon phases** & **age**  
✅ Computes **Zodiac sign** for a given date & location  
✅ Supports **iOS, macOS & tvOS**  
✅ High-precision **astronomical calculations**  

---

## ✅ Completed Features
- 🌙 Moon phase calculation
- 🌒 Moon rise/set time estimation
- 🏛 Zodiac sign determination
- 📅 Moon age computation
- 🖥 Cross-platform support (iOS, macOS, tvOS)

---

## 🔜 Planned Features
- 🌎 Location-based enhancements
- 📊 Improved accuracy in moon cycle prediction
- 🌓 Visualization of moon phases
- 📡 API integration for live astronomical data
- 📆 Custom date range support

---

## 🚀 Installation
```swift
    .package(url: "https://github.com/emvakar/EKAstrologyCalc.git", from: "1.0.6")
```
- Requires **Xcode 14+**
- Supports **iOS 15+**, **macOS 14+**, **tvOS 15+**

---

## 📖 Usage

To use EKAstrologyCalc, import the module and create an instance of `MoonPhaseCalculator`. The example below demonstrates how to retrieve moon phase details and zodiac sign based on the current date and location.

```swift
import UIKit
import CoreLocation
import EKAstrologyCalc

class ViewController: UIViewController {

    let location = CLLocation(latitude: 55.751244, longitude: 37.618423) // Moscow
    var moonPhaseManager: EKAstrologyCalc!

    override func viewDidLoad() {
        super.viewDidLoad()

        moonPhaseManager = EKAstrologyCalc(location: location)
        let info = moonPhaseManager.getInfo(date: Date())

        print("🌍 Current location: \(info.location.coordinate)")
        print("📅 Calculation date: \(info.date)")

        info.moonModels.forEach {
            print("🌙 --- Lunar Day ---")
            print("🔢 Lunar Day Number: ", $0.age)
            print("🌅 Moonrise: ", $0.rise?.toString(style: .short) ?? "No data")
            print("🌄 Moonset: ", $0.set?.toString(style: .short) ?? "No data")
            print("♈ Lunar Zodiac Sign: ", $0.sign)
        }

        print("🌑 Moon Phase: \(info.phase)")
        print("📈 Moon Trajectory: \(info.trajectory)")
    }
}
```

This will output on debug console:
```
🌍 Current location: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423)
📅 Calculation date: 2025-02-09 04:53:16 +0000
🌙 --- Lunar Day ---
🔢 Lunar Day Number:  11
🌅 Moonrise:  09.02.2025, 12:46
🌄 Moonset:  10.02.2025, 07:53
♈ Lunar Zodiac Sign:  cancer
```

---

## 🛠 Technologies Used
- **Swift**
- **Foundation & CoreLocation**
- **Astronomical Algorithms**
- **UIKit & SwiftUI** (if UI included)

---

## 🤝 Contributing
Want to improve **EKAstrologyCalc**? Feel free to:
- Submit issues 🚀
- Open pull requests 🔥
- Suggest features 🌟

---

## 📜 License
This project is licensed under the **MIT License** – see the [LICENSE](https://github.com/emvakar/EKAstrologyCalc/blob/main/LICENSE) file for details.

---

## 🌐 Connect with Me
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/emvakar)  
[![Telegram](https://img.shields.io/badge/Telegram-@emvakar-blue?style=flat&logo=telegram)](https://t.me/emvakar)  

---

🌙 **Enjoy using EKAstrologyCalc?** Give it a ⭐ to support development!
