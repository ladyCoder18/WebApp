import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/userdata.dart';
import '../services/database_helper.dart';
import 'admin_landing_page.dart';
import 'login_page.dart';

class EditDataPage extends StatefulWidget {
  @override
  _EditDataPageState createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  List<UserData> _userData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<UserData> userData = await DatabaseHelper.instance.getAllData();
    setState(() {
      _userData = userData;
    });
  }

  Widget _getCellValue(dynamic value) {
    return value != null
        ? Icon(Icons.check, color: Colors.green)
        : Container(); // Return an empty container if value is null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View/Modify Data'),
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Set horizontal scrolling here
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: [
              DataColumn(label: Text('FirstName')),
              DataColumn(label: Text('LastName')),
              DataColumn(label: Text('EmailID')),
              DataColumn(label: Text('PhoneNumber')),
              DataColumn(label: Text('DOB')),
              DataColumn(label: Text('SSN')),
              DataColumn(label: Text('Address')),
              DataColumn(label: Text('CreditCardNumber')),
              DataColumn(label: Text('DriverLicenseNumber')),
            ],
            rows: _userData
                .map(
                  (user) => DataRow(
                selected: false,
                onSelectChanged: (selected) {
                  // Implement logic to handle row selection
                },
                cells: [
                  DataCell(Text(user.firstName)),
                  DataCell(Text(user.lastName)),
                  DataCell(Text(user.emailId)),
                  DataCell(Text(user.phoneNumber)),
                  DataCell(_getCellValue(user.dateOfBirth)),
                  DataCell(_getCellValue(user.ssn)),
                  DataCell(_getCellValue(user.address)),
                  DataCell(_getCellValue(user.creditCardNumber)),
                  DataCell(_getCellValue(user.driverLicenseNumber)),
                ],
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
}
