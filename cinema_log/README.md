# cinema_log

Cinema Log App – README (VS Code + TMDB .env Setup)

Overview

This app uses:

Flutter (Frontend)
Firebase (optional backend)
TMDB for movie data

The TMDB API key is NOT stored directly in code.
It must be placed in a .env file.

Prerequisites

Install the following:

Flutter SDK → https://docs.flutter.dev/get-started/install
VS Code → https://code.visualstudio.com/

Android Studio → https://developer.android.com/studio
(Required for Android Emulator)

VS Code Extensions:
Flutter
Dart

Verify Flutter:

flutter doctor


Step 1: Open Project in VS Code

Open VS Code
Click File → Open Folder
Select:
cinema_log


Step 2: Install Dependencies

Open terminal in VS Code:

flutter pub get


Step 3: Create the .env File (IMPORTANT)

Where to Place It

Create a file named:

.env

Inside this folder:

lib/env/


What to Put in .env

Add your TMDB API key like this:

API_KEY=123456abcdefg

No quotes, no spaces


Step 4: Get a TMDB API Key

Go to: https://www.themoviedb.org/
Create an account
Go to Settings → API
Request a key


If You DO NOT Have a TMDB API Key

The app will:

Not load movies
Possibly crash or show empty data

Common errors:

API returns nothing
“Invalid API key”
App stuck loading

Fix:

Make sure .env is in lib/env/
Make sure variable name is EXACT:
API_KEY=123456abcdefg

Restart app after changes:

flutter clean
flutter pub get
flutter run

or run

dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
for this to run make goto your VS Code terminal and type cd cinema_log


Step 5: Run the App (VS Code)

Start Emulator First (Android Studio)

Open Android Studio
Click "More Actions" (or Configure on older versions)
Open "Device Manager"

Create an Emulator (first time only):

Click "Create Device"
Select a device (ex: Pixel 6)
Click "Next"
Download a system image (recommended: API 33 or latest)
Click "Finish"

Start the Emulator:

Click the ▶ (Play) button next to your device
Wait until the emulator fully boots (this may take a minute)

IMPORTANT:
Leave the emulator running in the background


Verify Device in VS Code

Open terminal in VS Code and run:

flutter devices

You should see something like:

emulator-5554 • Android SDK built for x86 • android-x64

If you do NOT see a device:
- Make sure emulator is running
- Restart VS Code
- Run flutter doctor


Run App from VS Code

Option 1 (Terminal):

flutter run


Option 2 (VS Code UI):

Press F5

OR

Click "Run and Debug" on the left sidebar
Click "Run"


Select Device in VS Code (if multiple devices):

Bottom right corner of VS Code → Click device name
Select your emulator


Hot Reload (VERY IMPORTANT)

While app is running:

Press r in terminal → Hot Reload
Press R → Full Restart


Expected Result

App launches on emulator
If .env is correct → movie data loads
If not → app may show empty/demo data


Troubleshooting

API still not working

Check:

.env file name is exactly .env
File is inside lib/env/
No extra spaces in key


Changes not applying

Run:

flutter clean
flutter pub get
flutter run


No device found

flutter devices

If still empty:
- Restart emulator
- Restart VS Code
- Run flutter doctor


Emulator not starting

Open Android Studio
Go to Device Manager
Restart emulator

If still broken:
Cold Boot Device (from dropdown menu)


Project Structure

lib/
 ├── env/
 │    └── .env        ← TMDB API key goes here
 ├── screens/
 ├── models/
 └── services/


Security Note:

Never upload .env to GitHub
Add .env to .gitignore


Quick Summary:

Situation	Fix
No API key	Create TMDB account
.env missing	Add file to lib/env/
API not working	Check key + restart app
Just demo	Use mock data


Goal

After setup, you should be able to:

Run the app in VS Code
Load real movie data using TMDB
Use Android Studio emulator
