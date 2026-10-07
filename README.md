<div align="center">

# 🏥 Medico

### A modern healthcare companion app built with Flutter

Book doctor appointments, order medicine, manage prescriptions, and track your medical history — all in one clean, professional mobile experience.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📱 About

**Medico** is a full-featured healthcare mobile application that connects patients with doctors and pharmacies. It was built to explore real-world app architecture: clean data models, a dedicated service layer, and proper state management — instead of throwing everything into one file.

## ✨ Features

- 🔐 **Authentication** — Sign up and log in with email/password
- 👨‍⚕️ **Doctor Directory** — Browse doctors by specialty, rating, and distance
- ⭐ **Favourites** — Save doctors for quick access later
- 📅 **Appointment Booking** — Book, view, and manage upcoming/past appointments
- 💊 **Medicine & Pharmacy** — Search medicine, browse nearby pharmacies, view offers, and place orders
- 📋 **Order History** — Track current and past medicine orders
- 📄 **Medical Reports** — View and manage personal medical records
- 🔍 **Smart Search** — Unified search across doctors, medicine, and reports with recent search history, real GPS-based distance, and advanced filters
- 💬 **Doctor Reviews** — Read and leave reviews for doctors

## 🛠️ Tech Stack & Architecture

| Layer | Approach |
|---|---|
| **Language / Framework** | Flutter & Dart |
| **State Management** | Provider |
| **Networking** | `http` package, consumed through a dedicated service layer |
| **Location** | `geolocator` — real device GPS for distance-based doctor search |
| **Data Layer** | Typed models (`Doctor`, `Booking`, `Medicine`, `Pharmacy`, `Offer`, `MedOrder`) with `fromJson` / `toJson` |
| **Backend** | REST APIs (mockapi.io) |

The project follows a layered structure to keep UI, data, and business logic separated:

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or higher)
- Android Studio or VS Code with the Flutter extension
- An Android emulator or physical device

### Installation

```bash
git clone https://github.com/MohamedEl3zpawy/medico.git
cd medico
flutter pub get
flutter run
```

## 📸 Screenshots

<div align="center">
<img src="screenshots/splash.png" width="200" />
<img src="screenshots/Welcome page.png" width="200" />
<img src="screenshots/home.png" width="200" />
<img src="screenshots/bookings.png" width="200" />
<img src="screenshots/favourite.png" width="200" />
<img src="screenshots/profile.png" width="200" />
</div>

## 👤 Author

**Mohamed Sameh**

- Portfolio: [mohamedel3zpawy.github.io](https://mohamedel3zpawy.github.io)
- GitHub: [@MohamedEl3zpawy](https://github.com/MohamedEl3zpawy)
- LinkedIn: [Mohamed Sameh](https://www.linkedin.com/in/mohamed-sameh-11437b380)

---

<div align="center">
Made with Flutter 💙
</div>