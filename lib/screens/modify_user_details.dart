import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webapp/screens/login_page.dart';
import '../services/database_helper.dart';
import '../models/user.dart';
import '../models/userdata.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'admin_landing_page.dart';

class ModifyUserDetailsPage extends StatefulWidget {
  @override
  _ModifyUserDetailsPageState createState() => _ModifyUserDetailsPageState();
}

class _ModifyUserDetailsPageState extends State<ModifyUserDetailsPage> {
  List<User> _users = [];
  List<UserData> _data = [];
  List<User> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<User> users = await DatabaseHelper.instance.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _loadData() async {
    List<UserData> data = await DatabaseHelper.instance.getAllData();
    setState(() {
      _data = data;
    });
  }

  void _deleteSelectedUsers() {
    // Delete selected users from the database
    for (User user in _selectedUsers) {
      DatabaseHelper.instance.deleteUser(user.emailId);
    }

    // Clear the selected users list
    _selectedUsers.clear();

    // Reload users after deletion
    _loadUsers();

    // Show a SnackBar to indicate that users have been deleted
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Selected users deleted successfully.'),
    ));
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xls', 'xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String contents = await file.readAsString();
      List<List<dynamic>> rowsAsListOfValues =
      CsvToListConverter().convert(contents);

      // Check if there is at least one row in the CSV
      if (rowsAsListOfValues.isNotEmpty) {
        // Extract the header row
        List<dynamic> headerRow = rowsAsListOfValues[0];

        // Find column indices for each field
        int firstNameIndex = headerRow.indexOf('First Name');
        int lastNameIndex = headerRow.indexOf('Last Name');
        int emailIdIndex = headerRow.indexOf('Email');
        int genderIndex = headerRow.indexOf('Gender');
        int dateOfBirthIndex = headerRow.indexOf('Date of Birth');
        int phoneNumberIndex = headerRow.indexOf('Phone Number');
        int ssnIndex = headerRow.indexOf('SSN');
        int addressIndex = headerRow.indexOf('Address');
        int cityIndex = headerRow.indexOf('City');
        int stateIndex = headerRow.indexOf('State');
        int creditCardNumberIndex = headerRow.indexOf('Credit Card Number');
        int cvvIndex = headerRow.indexOf('CVV');
        int driverLicenseNumberIndex = headerRow.indexOf('Driver License Number');

        // Import new data from the CSV file
        for (int i = 1; i < rowsAsListOfValues.length; i++) {
          List<dynamic> row = rowsAsListOfValues[i];

          String firstName = firstNameIndex != -1 ? row[firstNameIndex].toString() : '';
          String lastName = lastNameIndex != -1 ? row[lastNameIndex].toString() : '';
          String emailId = emailIdIndex != -1 ? row[emailIdIndex].toString() : '';
          String gender = genderIndex != -1 ? row[genderIndex].toString() : '';
          String dateOfBirth = dateOfBirthIndex != -1 ? row[dateOfBirthIndex].toString() : '';
          String phoneNumber = phoneNumberIndex != -1 ? row[phoneNumberIndex].toString() : '';
          String ssn = ssnIndex != -1 ? row[ssnIndex].toString() : '';
          String address = addressIndex != -1 ? row[addressIndex].toString() : '';
          String city = cityIndex != -1 ? row[cityIndex].toString() : '';
          String state = stateIndex != -1 ? row[stateIndex].toString() : '';
          String creditCardNumber = creditCardNumberIndex != -1 ? row[creditCardNumberIndex].toString() : '';
          String cvv = cvvIndex != -1 ? row[cvvIndex].toString() : '';
          String driverLicenseNumber = driverLicenseNumberIndex != -1 ? row[driverLicenseNumberIndex].toString() : '';
          String createdDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

          UserData newData = UserData(
            firstName: firstName,
            lastName: lastName,
            emailId: emailId,
            gender: gender,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            ssn: ssn,
            address: address,
            city: city,
            state: state,
            creditCardNumber: creditCardNumber,
            cvv: cvv,
            driverLicenseNumber: driverLicenseNumber,
            createdDate: createdDate,
          );

          await DatabaseHelper.instance.insertData(newData);
        }

        // Reload data after importing
        _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV data imported successfully.'),
          ),
        );
      }
    }
  }


  Future<void> _saveChanges(String emailId, bool canWrite) async {
    // Save changes to the database
    await DatabaseHelper.instance.updateUserPermissions(emailId, canWrite);

    // Reload users after saving changes
    _loadUsers();

    // Show a SnackBar to indicate that changes have been saved
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Changes saved successfully.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify User Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
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
      body: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _importCSV,
                    child: Text('Import CSV'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _deleteSelectedUsers,
                    child: Text('Delete Selected Users'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('FirstName')),
                  DataColumn(label: Text('LastName')),
                  DataColumn(label: Text('Password')),
                  DataColumn(label: Text('UserId')),
                  DataColumn(label: Text('Can Write')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _users
                    .map(
                      (user) => DataRow(
                        selected: _selectedUsers.contains(user),
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected != null && selected) {
                              _selectedUsers.add(user);
                            } else {
                              _selectedUsers.remove(user);
                            }
                          });
                        },
                        cells: [
                          DataCell(Text(user.firstName)),
                          DataCell(Text(user.lastName)),
                          DataCell(Text(user.password)),
                          DataCell(Text(user.userId)),
                          DataCell(Text(user.canWrite ? 'Yes' : 'No')),
                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    bool _canWrite = user.canWrite;
                                    return AlertDialog(
                                      title: Text('Edit Permissions'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          CheckboxListTile(
                                            title: Text('Can Write'),
                                            value: _canWrite,
                                            onChanged: (value) {
                                              setState(() {
                                                _canWrite = value ?? false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _saveChanges(
                                                user.emailId, _canWrite);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Edit Permissions'),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
