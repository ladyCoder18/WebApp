import 'package:flutter/material.dart';
import 'package:webapp/screens/admin_landing_page.dart';
import 'package:webapp/screens/reset_password_page.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;

    // Check if the user is an admin
    if (username == 'admin' && password == 'admin') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AdminLandingPage()));
    } else {
      User? user = await DatabaseHelper.instance
          .getUserByUserIdAndPassword(username, password);

      if (user != null) {
        // Regular user login successful, navigate to display details page
        print('Login Successful');
        Navigator.pushNamed(context, '/displayDetails');
      } else {
        // Login failed, show an error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Invalid username or password.'),
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

    //Clear the contents
    usernameController.clear();
    passwordController.clear();
  }

  void _forgotPassword(BuildContext context) {
    // Navigate to the reset password page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _forgotPassword(context);
              },
              child: Text('Forgot Password'),
            ),
          ],
        ),
      ),
    );
  }
}
