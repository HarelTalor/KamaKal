# KamaKal 🔥

KamaKal is a native iOS application built with SwiftUI and SwiftData that helps users track their daily calories using AI image recognition. Users simply snap a photo of their meal, provide a brief description, and Google's Gemini multimodal AI automatically identifies the ingredients and estimates the caloric breakdown.

## Features

- **Personalized Onboarding:** Calculates your Total Daily Energy Expenditure (TDEE) and calorie target using the Mifflin-St Jeor equation.
- **AI Meal Capture:** Take photos of food and let Google Gemini (`gemini-2.0-flash`) parse the ingredients and calories.
- **Daily Dashboard:** Track your real-time progress against your daily target with an animated progress ring.
- **History Logs:** View your past meals organized by day, with a detailed breakdown of what you ate.
- **Local First Data:** Uses `SwiftData` to store everything securely on your device.
- **Cloud Ready:** Architecture is prepared to sync to Supabase.

---

## 🚀 Getting Started

Because this is a native iOS application, you will need a Mac to build and run the app.

### Prerequisites

1. **Mac Computer** running macOS.
2. **Xcode 15+** (Available free from the Mac App Store).
3. **Google Gemini API Key** (Get one at [Google AI Studio](https://aistudio.google.com/apikey)).
4. **Supabase Account** (Get one at [Supabase](https://supabase.com/)).

### 1. Project Setup

1. Open Xcode and select **File > Open**, then select the `KamaKal` directory containing `KamaKal.xcodeproj`. *(If you haven't created the `.xcodeproj` yet, create a new iOS App project in Xcode, name it KamaKal, and drag all the Swift files into the target).*
2. Add the Supabase Swift SDK via Swift Package Manager:
   - Go to **File > Add Package Dependencies...**
   - Search for `https://github.com/supabase-community/supabase-swift`
   - Set version rule to **Up to Next Major** starting from `3.0.0`
   - Click **Add Package**.

### 2. Configure Environment Variables

Open `KamaKal/Services/Constants.swift` and replace the placeholder strings with your actual API keys. (You can reference the `.env.template` file in the root directory for exactly what keys are needed).

```swift
enum Constants {
    // Supabase
    static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

    // Google Gemini
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY"
    static let geminiModel = "gemini-2.0-flash"
}
```

---

## 🧪 How to Run and Test

### Running in the Simulator
1. In the top bar of Xcode, select a simulator (e.g., **iPhone 15 Pro**).
2. Press the **Play** button (`Cmd + R`) to build and run the app.
3. *Note: The Xcode Simulator can access your Mac's photo library to test the Meal Capture photo picker.*

### Running on a Physical Device
1. Plug your iPhone into your Mac.
2. In Xcode, go to the project settings by clicking `KamaKal` at the top of the file navigator.
3. Under the **Signing & Capabilities** tab, select your Personal Team (you will need to sign in with your Apple ID).
4. Select your iPhone from the device dropdown at the top.
5. Press **Play** (`Cmd + R`).

### Testing the AI
1. Go through the onboarding to set your calorie target.
2. Tap the `+` button on the dashboard.
3. Select an image of food from your photo library.
4. Type a short description (e.g., "Chicken Caesar Salad").
5. Tap **Analyze with AI** and wait for the Gemini response.
6. Tap **Save Meal** to write the data to SwiftData.

---

## 📦 How to Deploy

To distribute the app to external users or publish it to the App Store, you need an **Apple Developer Program membership** ($99/year).

### 1. Internal Testing via TestFlight
1. In Xcode, select **Any iOS Device (arm64)** as the run destination.
2. Go to **Product > Archive**.
3. Once the archive completes, the Organizer window will open.
4. Click **Distribute App** and select **TestFlight & App Store**.
5. Follow the prompts to upload the build to App Store Connect.
6. Once uploaded and processed, you can invite testers via email or a public TestFlight link in App Store Connect.

### 2. App Store Release
1. In [App Store Connect](https://appstoreconnect.apple.com/), create a new app record for KamaKal.
2. Provide your app metadata (Description, Screenshots, Keywords, Privacy Policy).
3. Select the build you uploaded during the TestFlight phase.
4. Submit the app for **App Review**. Once approved, it will be available globally on the App Store!