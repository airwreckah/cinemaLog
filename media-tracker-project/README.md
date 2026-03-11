# Database & Persistence Setup Guide

*(Media Tracker Project)*

This README explains how to run and test the **database and persistence layer** of the Media Tracker project. These instructions assume you are starting from **zero setup**.

The database layer handles:

* Storing media (movies and TV shows)
* Storing custom lists
* Connecting lists and media through a junction table
* Updating watch status
* Removing media from lists
* Persisting data using a cloud database

This portion of the project also integrates media search data from the API provided by The Movie Database and stores persistent data using the cloud database service from Firebase.

---

# 1. Download the Project

First download the repository from GitHub.

### Option A — Using Git (Recommended)

Install Git if you do not already have it.

Download from:
https://git-scm.com/downloads

Then open a terminal and run:

```
git clone https://github.com/YOUR_TEAM_REPOSITORY/project-name.git
```

Move into the project folder:

```
cd project-name
```

---

### Option B — Download ZIP

If you do not want to use Git:

1. Open the repository on GitHub
2. Click **Code**
3. Click **Download ZIP**
4. Extract the folder anywhere on your computer

---

# 2. Editors You Can Use

You do **NOT** need a specific editor to run this project.

The database layer was developed using **CML and Notepad++**, but any editor will work.

### Recommended Editors

• Visual Studio Code
• Notepad++
• Sublime Text
• Vim

You can open the project folder with any of these tools.

---

# 3. Database Setup

The project uses the cloud database service from Firebase.

Only **one Firebase project is needed for the whole team**, but everyone should have access to it.

## Step 1 — Open Firebase Console

Go to:

https://console.firebase.google.com/

Open the team's Firebase project.

---

## Step 2 — Enable Firestore

Inside the Firebase console:

1. Click **Firestore Database**
2. Click **Create Database**
3. Choose **Test Mode** for development

---

## Step 3 — Verify Collections

Make sure the following collections exist:

```
media
customList
customListMedia
users
```

If they do not exist yet, they will be created automatically when the application writes data.

---

# 4. Firebase Configuration

Inside the code you will see a configuration section like this:

```javascript
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "..."
};
```

This configuration connects the application to the shared Firebase project.

If you receive connection errors, verify that the configuration matches the one provided in the Firebase console.

---

# 5. API Setup (Movie and TV Data)

The application retrieves media data from the API provided by The Movie Database.

The API key is already included in the project for development purposes.

If the API stops working you can generate your own key.

### Steps

1. Create an account at
   https://www.themoviedb.org/

2. Open **Settings**

3. Navigate to **API**

4. Generate an API key

Then replace the key in the code:

```
const API_KEY = "YOUR_API_KEY_HERE";
```

---

# 6. Running the Project

The database layer does **not require a backend server**.

You can run the application in several ways.

---

## Option 1 — Open the HTML File Directly

1. Locate:

```
index.html
```

2. Double-click the file

Your browser will open the application.

---

## Option 2 — Using a Local Web Server (Optional)

If your browser blocks local module imports, you may use a simple local server.

Examples:

### Python Server

```
python -m http.server
```

Then open:

```
http://localhost:8000
```

---

### Live Server Extension (Optional)

If you use Visual Studio Code you can install the **Live Server** extension and open the project that way.

---

# 7. Testing the Database Layer

Once the application is running:

1. Search for a movie or TV show
2. Click **Add to Tracker**
3. Change the watch **Status**
4. Remove items from the tracker

Then verify data appears in the Firebase Firestore database.

Expected database behavior:

* Media is stored in the **media** collection
* Lists are stored in **customList**
* Relationships are stored in **customListMedia**

---

# 8. Database Structure

The system uses the following data structure.

### Media

Stores movies and TV shows.

Example fields:

```
title
type
poster
overview
release
status
```

---

### CustomList

Stores user-created lists.

Example fields:

```
list_id
user_id
name
```

---

### CustomListMedia

This is a **junction table** connecting lists and media.

Example relationship:

```
CustomList A → Movie 1
CustomList A → Movie 2
CustomList B → Movie 1
```

---

# 9. CRUD Operations Implemented

The database layer supports the following operations:

Create

* Add media to database
* Add media to list

Read

* Load tracker list
* Retrieve media information

Update

* Update watch status

Delete

* Remove media from tracker

---

# 10. Development Notes

Before starting work:

1. Pull the latest version of the repository

```
git pull
```

After making changes:

```
git add .
git commit -m "describe your update"
git push
```

Do **not overwrite other team members’ modules**.

---

# 11. Troubleshooting

### API Returns No Results

Check that the API key is valid.

### Database Not Updating

Verify the Firebase configuration is correct.

### Buttons Not Working

Open the browser console (F12) to view JavaScript errors.

---

# End of Database Setup Guide

This guide covers everything required to run and test the database layer of the Media Tracker project.

NOTE: This should have the latest version of the back-end. When you search for a Movie Title/TV Show.
The results should have the poster,title,what media it is (TV Show or Movie), and Summary
If it does not show please use this url below.

https://test-c4d9f.web.app
