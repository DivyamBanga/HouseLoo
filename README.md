# 🏠 HouseLoo — Swipe. Match. Move In.

**HouseLoo** is a Flutter app that helps students and young professionals in **Waterloo** find housing — *Tinder style!*  
Swipe right to save a listing you like, swipe left to skip it.  
And with **gesture detection**, you can even swipe using your **hand in front of the camera** 👋.

---

## 🚀 Inspiration

Finding housing in Waterloo is often stressful — scattered listings, endless scrolling, and poor filtering.  
HouseLoo makes the process fun and visual.  
Just swipe through listings like you would on Tinder, and keep track of your favorites effortlessly.

---

## 🧩 Features

✅ **Swipe-Based Discovery**
- View housing listings as cards.
- Swipe **right** ❤️ to save, **left** ❌ to skip.
- Tap for more details (images, price, amenities).

✅ **Saved Listings**
- Quickly access your saved homes.
- Organized, easy-to-compare list view.

✅ **Gesture Control (Camera Swipe)**
- Use your webcam or phone camera to swipe hands left/right.
- Built using **MediaPipe/TFLite** (or OpenCV bindings).

✅ **Lightweight Web Scraper )**
- Pulls listings from various online sites using the beautiful soup library with python and google collab. 

✅ **Cross-Platform**
- Built entirely in **Flutter (Dart)**.
- Works on **mobile** and **web**.

---

## 🛠️ Tech Stack

| Layer | Technology | Description |
|-------|-------------|-------------|
| 💙 Frontend | Flutter (Dart) | Cross-platform UI framework |
| 🔄 State Management | Provider / Riverpod | Manage swipe & saved states |
| 👁️ Gesture Detection | MediaPipe / TFLite | Hand movement detection (left/right) |
| 📸 Camera Feed | Flutter Camera Plugin | Live hand-tracking |
| 🧠 Data | Web scraper (Python/Node) | Fetch mock listing data |
| 🧱 Backend | Firebase | Save user preferences |

---

## 🧠 How It Works

1. **Swipe Interface**
   - Uses [`swipe_cards`](https://pub.dev/packages/swipe_cards) for smooth card animations.
   - Local JSON file with mock listings.

2. **Gesture Detection**
   - Camera input processed using MediaPipe hand landmarks.
   - If hand moves → right → triggers “Save”.
   - If hand moves → left → triggers “Skip”.

3. **Saved Listings Page**
   - Stores all liked listings locally (in-memory or SQLite).

---

## 🧪 Setup & Run

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/houseloo.git
cd houseloo

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
