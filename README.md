# GroupTracker
GroupTracker is an application built to triangulate user's location and then store the coordinates on a database, allowing the user's friends to see exactly where they are located on a map.

## Program Details
- Uses the Flutter framework with DartLang.
- Implements mapping technology provided by the google maps API.
- Full user authentication capabilites.
- Utilizes Firebase OAuth Authentication and Firebase Realtime Database.
- Includes a friend-request system that grants other user's to the current user's location.
- Provides the ability to select which friends to track at any given point.
- Includes the exact time and date a user's location has been updated.
- Has the options of a blue or green theme.
- Usename, email and fullname can be easily updated at any time.
- Smaller than the average Android app, at only 7.7 MB vs the 11.5 MB average when built for release.
- Currently only supports Android, Apple forces the use of a Mac for IOS development (I don't have one).

## Usage
For development, a couple of things need to be setup first. These include the firebase databse and a keystore for APK signing.
To setup with firebase, create a firebase database, link this app's details to that database and ensure to include the google-services.json file in
the `android/app` directory of the project.

For creating a keystore and signing the APK, go to `android/key.properties` and ensure that the data entered to match each field relates
to the configuration of your keystore. The complete process for signing an APK has several steps, so for brevity I will not include full APK signing instructions here. I will reccomend going to the [Android Developers Website](https://developer.android.com/) for instructions on signing an APK.

When the Firebase Database is set up and the app is signed, it should be ready for release. Just use Flutter's command for building APK's to generate the app: `flutter build apk`.

## Screenshots
<img src="/Screenshots/Login.jpg" height="600">
<img src="/Screenshots/Markers.jpg" height="600">
<img src="/Screenshots/Drawer.jpg" height="600">
<img src="/Screenshots/Friends.jpg" height="600">
<img src="/Screenshots/Requests.jpg" height="600">
<img src="/Screenshots/Tracked.jpg" height="600">
