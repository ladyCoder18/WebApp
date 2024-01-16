import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webapp/screens/login_page.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import 'admin_landing_page.dart';

class RegistrationPage extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();

  String generateRandomPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*-_,.';
    final random = Random();
    return String.fromCharCodes(
      List.generate(
          12, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  bool isEmailValid(String email) {
    // Regular expression for validating an Email
    // This pattern ensures that the email follows a common email pattern
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    // Check if the email matches the pattern
    return emailRegex.hasMatch(email);
  }

  Future<String> generateUserId(String firstName, String lastName) async {
    // Take the first letter from the first name
    String firstNamePrefix = firstName.length >= 1 ? firstName.substring(0, 1).toLowerCase() : firstName.toLowerCase();
    String lastNameLowercase = lastName.toLowerCase();

    // Use the whole last name
    String userId = '$firstNamePrefix$lastNameLowercase';
    int count = 1;

    // Check if the generated userId already exists in the database
    while (await DatabaseHelper.instance.getUserByUserId(userId) != null) {
      userId = '$firstNamePrefix$lastName$count';
      count++;
    }

    return userId;
  }

  void _register(BuildContext context) async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String emailId = emailIdController.text;

    // Validate firstName, lastName, and emailId (add more validation logic if needed)
    if (firstName.isNotEmpty && lastName.isNotEmpty && emailId.isNotEmpty) {
      String generatedPassword = generateRandomPassword();
      String userId = await generateUserId(firstName, lastName);

      User newUser = User(
        firstName: firstName,
        lastName: lastName,
        password: generatedPassword,
        userId: userId,
        emailId: emailId,
        canWrite: false,
      );

      User? user = await DatabaseHelper.instance.getUserByUserId(emailId);

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
                    'Failed to register user. Please make sure to enter a valid email'),
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
        } else if (firstName.length < 2 || lastName.length < 2) {
          // Invalid input, show an error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Invalid first name or last name!'),
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
          int _id = await DatabaseHelper.instance.insertUser(newUser);
          if (_id != -1) {
            // Registration successful, show success message
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('User $userId registered successfully!'),
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
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Failure'),
                  content: Text('User $userId registration not successful!'),
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

    // Clear the contents
    firstNameController.clear();
    lastNameController.clear();
    emailIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New User'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to AdminLandingPage when back arrow is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminLandingPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: emailIdController,
              decoration: InputDecoration(
                labelText: 'Email Id',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _register(context);
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform logout logic, for example, clear session and navigate to HomePage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
