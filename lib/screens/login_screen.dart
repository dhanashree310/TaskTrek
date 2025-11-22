import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  bool rememberMe = false;
  bool passwordVisible = false;

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showSnack("Please enter your email to reset password.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showSnack("Password reset email sent!");
    } catch (e) {
      showSnack("Error sending reset email.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (lavender)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE6E6FA), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Centered Card
          Center(
            child: Container(
              width: size.width * 0.85,
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Login to continue",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple.shade200,
                      ),
                    ),
                    SizedBox(height: 25),

                    // Email Field
                    _buildInputField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),

                    // Password Field
                    _buildInputField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      obscureText: !passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10),

                    // Remember Me + Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (val) =>
                                  setState(() => rememberMe = val!),
                              side: BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2), // outline color & width
                              checkColor: Colors.white, // tick color
                              activeColor:
                                  Colors.deepPurple, // background when checked
                            ),
                            Text(
                              "Remember Me",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: forgotPassword,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Login Button
                    _buildButton(
                      text: "Login",
                      loading: loading,
                      onPressed: () async {
                        setState(() => loading = true);
                        try {
                          final user = await AuthService().login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          setState(() => loading = false);

                          if (user != null) {
                            Navigator.pushReplacementNamed(context, "/home");
                          } else {
                            showSnack(
                                "Login failed. Please check your credentials.");
                          }
                        } on FirebaseAuthException catch (e) {
                          setState(() => loading = false);

                          if (e.code == "user-not-found") {
                            showSnack(
                                "User not registered. Please register first.");
                          } else if (e.code == "wrong-password") {
                            showSnack("Incorrect password. Try again.");
                          } else {
                            showSnack("Login failed: ${e.message}");
                          }
                        } catch (e) {
                          setState(() => loading = false);
                          showSnack("Login failed. Please try again.");
                        }
                      },
                    ),
                    SizedBox(height: 15),

                    // Google Login
                    _buildOutlineButton(
                      text: "Sign in with Google",
                      loading: loading,
                      onPressed: () async {
                        setState(() => loading = true);
                        final user = await AuthService().googleLogin();
                        setState(() => loading = false);

                        if (user != null) {
                          Navigator.pushReplacementNamed(context, "/home");
                        } else {
                          showSnack("Google sign-in failed.");
                        }
                      },
                    ),
                    SizedBox(height: 15),

                    TextButton(
                      onPressed: () async {
                        setState(() => loading = true);
                        final user = await AuthService().guestLogin();
                        setState(() => loading = false);

                        if (user != null) {
                          Navigator.pushReplacementNamed(context, "/home");
                        } else {
                          showSnack("Guest login failed.");
                        }
                      },
                      child: Text(
                        "Continue as Guest",
                        style:
                            TextStyle(color: Colors.deepPurple, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input Field with label always visible
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        suffixIcon: suffixIcon,
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Colors.deepPurple.shade50.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Login Button
  Widget _buildButton({
    required String text,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
                text,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
      ),
    );
  }

  // Outline Button
  Widget _buildOutlineButton({
    required String text,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.deepPurple),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? CircularProgressIndicator(
                color: Colors.deepPurple, strokeWidth: 2)
            : Text(text,
                style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
      ),
    );
  }
}
