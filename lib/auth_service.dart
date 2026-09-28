import 'package:firebase_auth/package:firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. SIGN UP (Email & Password) - Duplicate rokega aur Verification bhegega
  Future<String?> signUpUser(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Account bante hi Verification Email bhej do
      await cred.user!.sendEmailVerification();
      return "Account created! Please check your email to verify.";
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Ye email already registered hai. Kripya login karein."; // Custom Error
      } else if (e.code == 'invalid-email') {
        return "Email ka format galat hai.";
      }
      return e.message;
    }
  }

  // 2. LOGIN - Sirf verified emails ko andar aane dega
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check karo ki email verify hua hai ya nahi
      if (!cred.user!.emailVerified) {
        // Agar verify nahi hai, toh wapas bahar phek do aur message do
        await _auth.signOut();
        return "Bhai pehle email verify karo! Inbox check karo.";
      }
      
      return "Success"; // Login successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Account nahi mila. Pehle Sign Up karo.";
      } else if (e.code == 'wrong-password') {
        return "Password galat hai.";
      }
      return e.message;
    }
  }

  // 3. FORGOT PASSWORD (Password Reset Link)
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset link tumhare email par bhej diya gaya hai.";
    } catch (e) {
      return "Error: $e";
    }
  }

  // 4. DELETE ACCOUNT PERMANENTLY
  Future<String?> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        return "Account hamesha ke liye delete ho gaya.";
      }
      return "Koi user login nahi hai.";
    } catch (e) {
      // Note: Delete karne se pehle user ko dubara login (re-authenticate) karna pad sakta hai security ke liye
      return "Error: $e";
    }
  }
}
