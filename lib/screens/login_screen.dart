import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/foundation/color.dart';
import 'package:first_project/screens/signUp_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../tabs/home_tabs.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _textPasswordFieldFocusNode = FocusNode();
  late bool _passwordVisibility;
  bool _isSigningUp = false;

  @override
  void initState() {
    // TODO: implement initState
    _passwordVisibility = false;
    super.initState();
  }

  void _setFocus() {
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthsProvider>(context);
    final color = MyColor();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Text(
                      "LOGIN TO YOUR ATTENDANCE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    focusNode: _textFieldFocusNode,
                    controller: _emailController,
                    style: TextStyle(color: color.primaryColor),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: color.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter your email" : null,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    focusNode: _textPasswordFieldFocusNode,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordVisibility = !_passwordVisibility;
                          });
                        },
                        icon: Icon(
                          _passwordVisibility
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: color.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: _passwordVisibility,
                    validator: (value) =>
                        value!.length < 6 ? "Password must be 6+ chars" : null,
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RegisterScreen())),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: color.mainColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isSigningUp = true;
                          });
                          showDialog(
                            context: context,
                            builder: (context) => Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            await authProvider.login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          }  catch (e) {
                            Navigator.pop(context); // Close the loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                          setState(() {
                            _isSigningUp = false;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        height: _isSigningUp ? 45:50,
                        width: _isSigningUp ? 480:500,
                        child: Transform.scale(
                          scale: _isSigningUp ? 0.95: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                                color: color.mainColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color: color.primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: color.primaryColor,
                        ),
                        children: [
                          TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: color.mainColor,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterScreen(),),
                                  );
                                }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
