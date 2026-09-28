import 'package:flutter/material.dart';
import 'auth_service.dart'; // Tumhari Auth Service file
import 'home_screen.dart'; // Login ke baad yahan jayega

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // UI States
  bool isLoginMode = true; // True = Sign In, False = Sign Up
  bool isPasswordHidden = true; // Password chupane/dikhane ke liye
  bool isLoading = false; // Loading spinner ke liye

  // ==========================================
  // MAIN ACTION: SIGN IN OR SIGN UP
  // ==========================================
  void _submitForm() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Basic Validation (Z++ Security Rule 1: Khali box aage nahi jayega)
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Bhai, Email aur Password dono daalna zaroori hai.");
      return;
    }

    setState(() => isLoading = true);

    String? result;
    if (isLoginMode) {
      // 🟢 LOGIN KARENGE
      result = await _authService.loginUser(email, password);
      if (result == "Success") {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        _showMessage(result ?? "Login fail ho gaya.");
      }
    } else {
      // 🔵 SIGN UP KARENGE
      result = await _authService.signUpUser(email, password);
      _showMessage(result ?? "Error in Sign Up.");
      if (result!.contains("Account created")) {
        // Sign up ke baad wapas Login mode me le aao
        setState(() => isLoginMode = true); 
      }
    }

    setState(() => isLoading = false);
  }

  // ==========================================
  // FORGOT PASSWORD
  // ==========================================
  void _forgotPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage("Password reset karne ke liye pehle apna Email type karo.");
      return;
    }
    
    setState(() => isLoading = true);
    String? result = await _authService.resetPassword(email);
    setState(() => isLoading = false);
    
    _showMessage(result ?? "Email check karo.");
  }

  // Snackbar dikhane ka function
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sleek Dark Theme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔹 LOGO & BRANDING
                const Center(
                  child: Icon(Icons.security, size: 60, color: Colors.white), // Yahan Ticbull Logo laga sakte ho
                ),
                const SizedBox(height: 20),
                const Text(
                  "TICBULL ID",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 3.0),
                ),
                const SizedBox(height: 10),
                Text(
                  isLoginMode ? "SECURE SIGN IN" : "CREATE ACCOUNT",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                ),
                const SizedBox(height: 40),

                // 🔹 EMAIL FIELD
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orangeAccent)),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 PASSWORD FIELD (WITH SHOW/HIDE)
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: isPasswordHidden, // Hide/Show logic
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordHidden ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orangeAccent)),
                  ),
                ),

                // 🔹 FORGOT PASSWORD (Sirf Login mode me dikhega)
                if (isLoginMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text("Forgot Password?", style: TextStyle(color: Colors.orangeAccent)),
                    ),
                  )
                else
                  const SizedBox(height: 20),

                const SizedBox(height: 20),

                // 🔹 MAIN BUTTON (SIGN IN / SIGN UP)
                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text(
                          isLoginMode ? "SIGN IN" : "SIGN UP",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                ),

                const SizedBox(height: 30),

                // 🔹 TOGGLE MODE (Don't have an account?)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLoginMode ? "New to Ticbull?" : "Already have an account?",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLoginMode = !isLoginMode; // Toggle mode
                        });
                      },
                      child: Text(
                        isLoginMode ? "Create Account" : "Sign In",
                        style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
