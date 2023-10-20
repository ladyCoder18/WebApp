import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/user.dart';
import '../models/userdata.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<User> _users = [];
  List<UserData> _data = [];

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load users when the page is initialized
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

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xls', 'xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String contents = await file.readAsString();
      List<List<dynamic>> rowsAsListOfValues = CsvToListConverter().convert(contents);

      // Import new data from the CSV file
      for (List<dynamic> row in rowsAsListOfValues) {
        String firstName = row[0].toString();
        String lastName = row[1].toString();
        String emailId = row[2].toString();
        String gender = row[3].toString();
        String dateOfBirth = row[4].toString();
        String phoneNumber = row[5].toString();
        String ssn = row[6].toString();
        String streetAddress = row[7].toString();
        String city = row[8].toString();
        String state = row[9].toString();
        String creditCardNumber = row[10].toString();
        String cvv = row[11].toString();
        String driverLicenseNumber = row[12].toString();

        // Check if entry already exists in the database
        // int existingId = await DatabaseHelper.instance.checkIfDataExistsWithEmailId(emailId);
        UserData newData = UserData(
            firstName: firstName,
            lastName: lastName,
            emailId: emailId,
            gender: gender,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            ssn: ssn,
            streetAddress: streetAddress,
            city: city,
            state: state,
            creditCardNumber: creditCardNumber,
            cvv: cvv,
            driverLicenseNumber: driverLicenseNumber);

        /*if (existingId != 0) {
          // If the entry exists, update it with the new values
          await DatabaseHelper.instance.updateData(existingId, newData);
        } else {*/
          // If the entry does not exist, insert a new entry
          await DatabaseHelper.instance.insertData(newData);
        //}
      }

      // Reload data after importing
      _loadData();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('CSV data imported successfully.'),
      ));
    }
  }

  Future<void> _saveChanges(String userName, bool canRead, bool canWrite) async {
    // Save changes to the database
    await DatabaseHelper.instance.updateUserPermissions(userName, canRead, canWrite);

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
        title: Text('Admin Dashboard'),
      ),
      body:  Column(
        children: <Widget>[
      ElevatedButton(
      onPressed: _importCSV,
      child: Text('Import CSV'),
    ),
      Expanded(
        child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          User user = _users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Row(
              children: <Widget>[
                Text('Can Read: ${user.canRead ? 'Yes' : 'No'}'),
                SizedBox(width: 16),
                Text('Can Write: ${user.canWrite ? 'Yes' : 'No'}'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    bool _canRead = user.canRead;
                    bool _canWrite = user.canWrite;
                    return AlertDialog(
                      title: Text('Edit Permissions'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CheckboxListTile(
                            title: Text('Can Read'),
                            value: _canRead,
                            onChanged: (value) {
                              setState(() {
                                _canRead = value ?? false;
                              });
                            },
                          ),
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
                            // Save changes when the user clicks 'Save'
                            _saveChanges(user.username, _canRead, _canWrite);
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
          );
        },
      ),
    )
        ]
    )
    );
  }
}
