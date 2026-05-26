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

## 🚀 Getting Started (Windows & Mac)

KamaKal is a native iOS application. Traditionally, this requires a Mac and Xcode. **However, this repository is configured with a fully automated CI/CD pipeline**, meaning you can deploy the app to your iPhone via TestFlight directly from GitHub, even if you are on Windows.

### Prerequisites

1. **Apple Developer Account** ($99/year) to use TestFlight.
2. **Google Gemini API Key** (Get one at [Google AI Studio](https://aistudio.google.com/apikey)).
3. **Supabase Account** (Get one at [Supabase](https://supabase.com/)).

---

## 💻 How to Deploy from Windows (No Mac Required)

We use **GitHub Actions** to build the app on Apple Silicon cloud runners and push it to TestFlight.

### 1. Set up GitHub Secrets
Before running the workflow, you must provide your API keys to the build environment. Go to your GitHub repository -> **Settings** -> **Secrets and variables** -> **Actions** and add the following repository secrets:

- `SUPABASE_URL`: e.g., `https://xyz.supabase.co`
- `SUPABASE_ANON_KEY`: Your Supabase public anon key
- `GEMINI_API_KEY`: Your Google Gemini API key

*The workflow automatically injects these keys into the app during compilation, keeping your source code safe.*

### 2. Apple Signing Certificates
To build an iOS app, you must provide Apple signing certificates as GitHub Secrets. See the `testflight_setup_guide.md` file (generated in the artifacts) for the exact step-by-step instructions on how to generate these from Windows using OpenSSL. You will need:
- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_PROVISIONING_PROFILE_BASE64`
- `APPSTORE_CONNECT_API_KEY_ID`
- `APPSTORE_CONNECT_ISSUER_ID`
- `APPSTORE_CONNECT_API_PRIVATE_KEY`
- `APPLE_TEAM_ID`
- `BUNDLE_IDENTIFIER`

### 3. Run the Workflow
Once the 11 secrets are configured:
1. Go to the **Actions** tab in GitHub.
2. Select **Deploy to TestFlight**.
3. Click **Run workflow** (or simply push code to the `main` branch).
4. Wait 10-15 minutes. The app will appear in the **TestFlight** app on your iPhone!

---

## 🍏 How to Run Locally (Mac Required)

If you have a Mac, you can run and debug the app directly in the Xcode Simulator.

### 1. Project Generation
This repository does not check in the `.xcodeproj` file to prevent merge conflicts. Instead, we generate it dynamically using `XcodeGen`.

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```
2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
3. Open `KamaKal.xcodeproj` in Xcode 15+.

### 2. Configure API Keys
Since you are building locally, you need to manually insert your API keys.
Open `KamaKal/Services/Constants.swift` and replace the placeholder strings:

```swift
enum Constants {
    static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY"
}
```
*(Do not commit these changes if the repository is public).*

### 3. Build and Run
1. Select a simulator (e.g., iPhone 15 Pro).
2. Press **Play** (`Cmd + R`).
3. You can now test the AI Meal Capture using the simulator's photo library!