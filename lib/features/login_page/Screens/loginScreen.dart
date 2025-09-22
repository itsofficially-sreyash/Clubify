import 'package:clubify/common/constants/colors.dart';
import 'package:clubify/common/widgets/scaffolds.dart';
import 'package:clubify/features/announcements/screens/announcementScreen.dart';
import 'package:clubify/features/home/Screens/homeScreen.dart';
import 'package:clubify/features/login_page/widgets/customTextField.dart';
import 'package:clubify/services/authService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _otpFocus = FocusNode();
  final Authservice authservice = Authservice();
  bool otpSent = false;
  bool userAlreadyPresent = false;
  bool isLoading = false;
  double height = 350;

  Future<void> sendOtp() async {
    try {
      setState(() {
        isLoading = true;
      });

      final users = await supabase.from("userProfile").select("email");

      List<String> emails = (users as List)
          .map((user) => user["email"] as String)
          .toList();

      if (emails.contains(_emailController.text.trim())) {
        setState(() {
          userAlreadyPresent = true;
        });
      }

      final response = await authservice.signIn(_emailController.text.trim());
      if (response == "OTP sent successfully on your email") {
        setState(() {
          otpSent = true;
        });
        SnackBars.showSuccess(context, response!);
        print("response: $response");
      }
    } catch (e) {
      SnackBars.showError(context, e.toString());
      print("error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> verifyOTP() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await authservice.verifyOtpAndHandleProfile(
        _emailController.text.trim(),
        _otpController.text.trim(),
        OtpType.email,
        userAlreadyPresent ? null : _nameController.text.trim(),
        context,
      );
      if (response != null) {
        SnackBars.showSuccess(context, "User Verified Successfully");
        print("response otp verification: $response");
        //navigtion to home screen
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(title: "CLUBIFY",)));
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      SnackBars.showError(context, "Error verifying OTP");
      print(e);
    }
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email address (e.g., example@aitpune.edu.in)";
    }
    if (!email.contains("aitpune.edu.in")) {
      return "Enter your college ID (example@aitpune.edu.in)";
    }
    return null;
  }

  String? _validateName(String? name) {
    if (name == null || name.isEmpty) {
      return "Please enter your name";
    }
    if (name.trim().length < 2) {
      return "Name must be at least 2 characters";
    }
    return null;
  }

  String? _validateOtp(String? otp) {
    if (otp == null || otp.isEmpty) {
      return 'Please enter the OTP';
    }
    if (otp.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  Widget increaseHeight(Size size) {
    setState(() {
      height = userAlreadyPresent ? size.height * 0.3 : size.height * 0.6;
    });
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              ClipPath(
                clipper: BezierClipper1(),
                child: Container(
                  // height: size.height / 1.5,
                  height: size.height,
                  width: double.infinity,
                  decoration: BoxDecoration(color: primaryColor),
                ),
              ),
              Positioned(
                top: size.height * 0.08,
                left: size.width * 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hello",
                      style: TextStyle(
                        fontFamily: "AveriaSerifLibre",
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontFamily: "AveriaSerifLibre",
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: size.height * 0.3,
                left: size.width * 0.05,
                child: Container(
                  width: size.width * 0.9,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Login Account",
                            style: TextStyle(
                              fontFamily: "AveriaSerifLibre",
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Sign in to continue",
                            style: TextStyle(
                              fontFamily: "AveriaSerifLibre",
                              fontWeight: FontWeight.w300,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Email Section
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Email Address",
                                style: TextStyle(
                                  fontFamily: "AveriaSerifLibre",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Customtextfield(
                            enabled: !otpSent,
                            controller: _emailController,
                            focusNode: _emailFocus,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            hintText: "Enter your college email ID",
                            suffixIcon: Icon(CupertinoIcons.mail_solid),
                          ),
                          SizedBox(height: 20),

                          // Send OTP Button or OTP Section
                          if (!otpSent)
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        sendOtp();
                                        increaseHeight(size);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Send OTP",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )
                          else ...[
                            // OTP Section
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Enter OTP",
                                  style: TextStyle(
                                    fontFamily: "AveriaSerifLibre",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Customtextfield(
                              controller: _otpController,
                              focusNode: _otpFocus,
                              validator: _validateOtp,
                              keyboardType: TextInputType.number,
                              hintText: "Enter 6-digit OTP",
                              suffixIcon: Icon(CupertinoIcons.lock_fill),
                            ),
                            userAlreadyPresent
                                ? SizedBox(height: 30)
                                : SizedBox(height: 15),

                            // Name Section (only for new users)
                            if (userAlreadyPresent == false) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Full Name",
                                    style: TextStyle(
                                      fontFamily: "AveriaSerifLibre",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Customtextfield(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                validator: _validateName,
                                keyboardType: TextInputType.text,
                                hintText: "Enter your full name",
                                suffixIcon: Icon(CupertinoIcons.person_fill),
                              ),
                              SizedBox(height: 30),
                            ],

                            // Verify OTP Button
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        verifyOTP();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Verify OTP",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            SizedBox(height: 15),

                            // Change Email Button
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  otpSent = false;
                                  userAlreadyPresent = false;
                                  _otpController.clear();
                                  _nameController.clear();
                                  height = 350;
                                });
                              },
                              child: Text(
                                "Change Email",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailFocus.dispose();
    _otpFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }
}

class BezierClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var height = size.height;
    var width = size.width;
    var heightOffset = height * 0.6;
    Path path = Path();
    path.lineTo(0, height - heightOffset);
    path.quadraticBezierTo(
      width * 0.7,
      height * 0.7,
      width,
      height - heightOffset,
    );
    path.lineTo(width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
