# ex libris moi 📚: your personal library

### 📲 App Description

Ex Libris Moi is a personal library management system that helps users catalog their books and media, track lending activities, and explore new titles. The app provides an elegant and minimalist user interface for organizing collections and interacting with friends or the community.

## ↘️ Progress Updates

This section highlights the progress made in developing the app. Features are marked as complete or in progress.

- 12/10/2024:
	- Demo video of completed app and brief run through of code. 

[![YouTube Video for Demo](https://img.youtube.com/vi/e-lN1MQIWqg/0.jpg)](https://www.youtube.com/watch?v=e-lN1MQIWqg)


- 12/05/2024:
	- Added ability for users to scan ISBN/UPC barcodes to add media.
	- Tab-based navigation between Home, Discover, Lending, and Profile screens implemented.

<img src="/design_gifs/dec5update.gif" width=300 height=auto />	

- 11/30/2024:
	- Created and integrated user authentication system.
	- Designed wireframes for Home and Lending screens.
- 11/20/2024:
	- Completed initial project setup (repo creation, boilerplate code).

# Product Spec Design

## 🧾 User Stories

The following are features within the app that the user is able to do. They are separated by "must-have" (required) and "nice-to-have" (optional).

#### Required Stories

For Ex Libris Moi, I identified the following required features which a user needs to be able to perform the app to work:

- [X] User is able to add, edit, and delete books or media from a personal library
    - [X] *User can scan ISBN/UPC barcode to add media via external API*
    - [ ] User can search and filter by title, author, genre, or year
- [ ] User is able to explore new books/media through an external API
    - [ ] User is able to add books from discovery to a wishlist
- [ ] User can check-in/check-out books to track lending and borrowing
    - [ ] Record borrower details (name, profile, contact)
    - [ ] Mark items as returned
- [X] User is able to manage user account and log off
- [X] Tab-based navigation with Home, Discover, Community (optional), Lending, and Profile

#### Optional Stories
- [ ] User can share collections or book recommendations
- [ ] View borrowing stats or ratings of shared titles
- [ ] User can send reminders for overdue or upcoming returns
- [ ] Wishlist is able to lead to an online store to buy book

## 🤳 Screens

The following are the screens that the user will encounter while working in the app. Like the features, they are separated by required and optional.

### Required Screens

- Home Screen
    - Displays the user's library collection
    - Includes search, filter, and sort functionalities
    - Allows user to scan new books into their collection
- Discover Screen
    - Shows feed of books/media from external sources
    - Allows users to add new items to a wishlist 
- Lending Screen
    - Tracks books lent out and borrowed
    - Includes status labels like "Due soon" and "Borrowed out"
    - Add new loans and mark items as returned
- Profile Screen
    - User account details and app settings
    - Options to log out
 
## Optional Screens

- Community Screen
    - A social feed for recommendations and shared collections
 
## 🔄️ Navigation Flow

### Tab Navigation (Tab to Screen)

- Home/overall personal library
- Discover new titles
- Lending
- Profile

### Flow Navigation with Interactive Wireframes

- Login/sign up screen => Home

<img src="/design_gifs/logintohome.gif" width=300 height=auto />

- Home => Add new book/media

<img src="/design_gifs/hometoaddbook.gif" width=300 height=auto />

- Discover titles => View wishlist
- (For future version) Community feed (Find friends) => Create post
- Lending/manage loans => Add new loan
- Profile => Login/sign up screen (if user logs out)

<img src="/design_gifs/otherfeatures.gif" width=300 height=auto />
