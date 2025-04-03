# Ex Libris Moi

## Description

Ex Libris Moi is a comprehensive library management application designed to help users catalog and manage their personal book collections efficiently. Built using Swift and integrated with Firebase, it offers real-time data synchronization and robust backend support.

## Features

- **Catalog Management:** Add, edit, and delete books from your personal library.
- **Search Functionality:** Quickly search and filter through your collection.
- **Borrowing Tracker:** Keep track of borrowed books and their return dates.
- **Firebase Integration:** Real-time data sync and user authentication.

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/bareyez/ex-libris-moi.git
   ```
2. **Navigate to the Project Directory:**
   ```bash
   cd ex-libris-moi
   ```
3. **Install Dependencies:**
   Ensure you have CocoaPods installed. If not, install it using:
   ```bash
   sudo gem install cocoapods
   ```
   Then, install the project dependencies:
   ```bash
   pod install
   ```
4. **Open the Project:**
   Open the `.xcworkspace` file in Xcode:
   ```bash
   open "ExLibrisMoi.xcworkspace"
   ```
5. **Firebase Configuration:**
   - **Obtain the `GoogleService-Info.plist` File:**
     - Log in to the [Firebase Console](https://console.firebase.google.com/).
     - Navigate to your project or create a new one.
     - Register your iOS app with the bundle identifier used in this project.
     - Download the `GoogleService-Info.plist` file.
   - **Add the Configuration File to the Project:**
     - Drag and drop the `GoogleService-Info.plist` file into the root of your Xcode project.
     - Ensure it's added to all targets when prompted.

## Usage

1. **Build and Run:**
   - In Xcode, select your target device or simulator.
   - Press `Cmd + R` or click on the run button to build and launch the app.
2. **Explore Features:**
   - Add new books to your collection.
   - Use the search bar to find specific titles.
   - Track borrowed books and set return reminders.

## Project Structure

The project follows a modular structure based on MVC principles:

```
ex-libris-moi/
├── ExLibrisMoi/
│   ├── Models/
│   │   └── Book.swift
│   ├── Views/
│   │   ├── BookCell.swift
│   │   ├── BookDetailView.swift
│   │   ├── LendingView.swift
│   │   ├── LoginView.swift
│   │   ├── SignUpView.swift
│   │   └── HomeView.swift
│   ├── Root/
│   │   └── ContentView.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── Base.lproj/
│   └── AppDelegate.swift
│
├── Pods/
├── Podfile
├── Podfile.lock
├── ExLibrisMoi.xcodeproj/
│
├── README.md
├── .gitignore
├── LICENSE
│
├── docs/
│   ├── brainstorming1_bryanreyes.md
│   └── brainstorming2_bryanReyes.md
│
├── design_gifs/
│   └── demo1.gif
│
└── GoogleService-Info.plist
```

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your enhancements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

> 💡 For more insights on structuring Swift projects, you might find this helpful: [The Best Way to Structure Your iOS Project](https://levelup.gitconnected.com/the-best-way-to-struct-your-ios-project-a2daee7dcb45)
