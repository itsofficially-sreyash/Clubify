import 'package:clubify/common/widgets/scaffolds.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authservice {
  final supabase = Supabase.instance.client;

  //sign in with otp
  Future<String?> signIn(String email) async {
    try {
      await supabase.auth.signInWithOtp(email: email);
      return "OTP sent successfully on your email";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }

  //verify otp and handle profile
  Future<String?> verifyOtpAndHandleProfile(
    String email,
    String otp,
    OtpType type,
    String? name,
    BuildContext context,
  ) async {
    try {
      final response = await supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: type,
      );
      if (response.user != null) {
        //auth successful
        try {
          final usersEmail = await supabase.from("userProfile").select("email");

          List<String> _emails = (usersEmail as List)
              .map((email) => email["email"] as String)
              .toList();

          if (!_emails.contains(email)) {
            await supabase.from("userProfile").upsert({
              "email": email,
              "name": name,
            });
            SnackBars.showSuccess(context, "User Profile Created Successfully");
          } else {
            SnackBars.showSuccess(context, "User logged in successfully");
          }
        } catch (e) {
          SnackBars.showError(context, "Error while creating user profile");
        }
      }
    } catch (e) {
      SnackBars.showError(context, "Error verifying OTP");
      print("error otp: $e");
    }
  }
}
