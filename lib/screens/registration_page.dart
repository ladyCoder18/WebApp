import 'dart:math';

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../services/email_service.dart';
import 'login_page.dart';

class RegistrationPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();

  String generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+[]{}|;:,.<>?';
    final random = Random();
    return String.fromCharCodes(
      List.generate(12, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }


  bool isEmailValid(String email) {
    // Regular expression for validating an Email
    // This pattern ensures that the email follows a common email pattern
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    // Check if the email matches the pattern
    return emailRegex.hasMatch(email);
  }

  void _register(BuildContext context) async {
    String username = usernameController.text;
    String emailId = emailIdController.text;

    // Validate username and password (add more validation logic if needed)
    if (username.isNotEmpty && emailId.isNotEmpty) {
      String generatedPassword = generateRandomPassword();
      User newUser = User(
          username: username,
          password: generatedPassword,
          emailId: emailId,
          canWrite: false);
      User? user = await DatabaseHelper.instance.getUserByEmailId(emailId);

      if (user != null) {
        // user already exists
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('User with the given emailId already exists!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        if (!isEmailValid(emailId)) {
          // Registration failed, show an error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(
                    'Failed to register user. Please make sure to enter valid email'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
        else if (username.length < 4) {
          // Invalid input, show an error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Invalid username!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          int userId = await DatabaseHelper.instance.insertUser(newUser);
          if (userId != -1) {
            // Registration successful, send email and show success message
            bool emailSent = await EmailService.sendEmail(emailId, username, generatedPassword);
            if (emailSent) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Success'),
                    content: Text('User $username registered successfully!'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Failure'),
                  content: Text('User $username registration not successful!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please make sure to enter all details'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    //Clear the contents
    usernameController.clear();
    emailIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person),
                  hintText: 'Min 4 characters',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            TextField(
              controller: emailIdController,
              decoration: InputDecoration(labelText: 'EmailId', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _register(context);
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to login page and remove the registration page from the stack
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                'Already have an account? Login here',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
