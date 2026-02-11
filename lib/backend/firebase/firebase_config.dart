import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyB5TaPZcQudOtHklE5Qtm0mIGmXO8WgZYQ",
            authDomain: "splitstack-6cb43.firebaseapp.com",
            projectId: "splitstack-6cb43",
            storageBucket: "splitstack-6cb43.firebasestorage.app",
            messagingSenderId: "872648307090",
            appId: "1:872648307090:web:6e263e3a68d4db63c9914b"));
  } else {
    await Firebase.initializeApp();
  }
}
