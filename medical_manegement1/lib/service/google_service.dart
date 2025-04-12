import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled sign-in
        return;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Finally, sign in
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      // Check if the user already exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        // User already exists, handle accordingly (e.g., show message or navigate to home)
        print("User already exists");
        Navigator.pushReplacementNamed(context, '/buttom_bar');
        // Handle navigation or show message as needed
        return;
      }

      // Fetch additional user information from Google
      final googleSignIn = GoogleSignIn();
      final googleAccount = await googleSignIn.signInSilently();
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      final googleUserInfo = googleSignInAccount!.displayName;

      final googleProfileImageUrl = googleSignInAccount.photoUrl;
      final googleEmail = googleSignInAccount.email;
      const googlePhoneNumber = null;

      // Add user information to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': googleUserInfo,
        'email': googleEmail,
        'profileImageUrl': googleProfileImageUrl,
        'phoneNumber': googlePhoneNumber ?? "",
        'gender':
        '', // You can modify this based on how you fetch gender information
        'tokens': 0,
      });

      // Navigate to home page after successful sign-in
      Navigator.pushReplacementNamed(
          context, '/buttom_bar'); // Replace with your home page route
    } catch (error) {
      // Handle sign-in errors
      print("Sign in with Google failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in with Google failed. Please try again.'),
        ),
      );
    }
  }
}
