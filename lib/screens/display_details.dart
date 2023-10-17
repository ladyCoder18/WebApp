import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/database_helper.dart';

class DisplayDetailsPage extends StatefulWidget {
  @override
  _DisplayDetailsPageState createState() => _DisplayDetailsPageState();
}

class _DisplayDetailsPageState extends State<DisplayDetailsPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  List<Map<String, dynamic>> _data = []; // List to store retrieved data
  int _currentPage = 1;
  int _pageSize = 10;

  Future<void> _getData() async {
    String date = dateController.text;
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.getPagedData(date, _currentPage, _pageSize);
    setState(() {
      _data = data;
    });
  }

  Future<void> _exportToCSV() async {
    // Generate CSV data from _data list
    String csvData = 'FirstName, LastName, EmailId, Gender, DOB, PhoneNumber, SSN, StreetAddress, City, State, CreditCardNumber,CVV, DrivingLicenseNumber\n';
    for (var item in _data) {
      csvData += '${item['firstName']},'
          ' ${item['lastName']},'
          ' ${item['emailId']},'
          ' ${item['gender']},'
          ' ${item['dob']},'
          ' ${item['phoneNumber']},'
          ' ${item['ssn']},'
          ' ${item['streetAddress']},'
          '${item['city']},'
          ' ${item['state']},'
          ' ${item['creditCardNumber']},'
          ' ${item['cvv']},'
          ' ${item['drivingLicenseNumber']}\n'; // Update with actual field names
    }

    // Saving CSV data to a file
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/data.csv';
    File file = File(filePath);
    await file.writeAsString(csvData);

    // Copy CSV data to clipboard for easy sharing
    await Clipboard.setData(ClipboardData(text: csvData));


    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('CSV data exported and copied to clipboard.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    User user = ModalRoute.of(context)?.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: Text('Display Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportToCSV,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Enter Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Enter Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _getData();
              },
              child: Text('Get Data'),
            ),
            SizedBox(height: 20),
            _data.isNotEmpty
                ? DataTable(
              columns: [
                DataColumn(label: Text('FirstName')),
                DataColumn(label: Text('LastName')),
                DataColumn(label: Text('EmailID')),
                DataColumn(label: Text('Gender')),
                DataColumn(label: Text('DOB')),
                DataColumn(label: Text('PhoneNumber')),
                DataColumn(label: Text('SSN')),
                DataColumn(label: Text('StreetAddress')),
                DataColumn(label: Text('City')),
                DataColumn(label: Text('State')),
                DataColumn(label: Text('CreditCardNumber')),
                DataColumn(label: Text('CVV')),
                DataColumn(label: Text('DriverLicenseNumber')),
              ],
              rows: _data
                  .map(
                    (item) => DataRow(
                  cells: [
                    DataCell(Text(item['FirstName'])),
                    DataCell(Text(item['LastName'])),
                    DataCell(Text(item['EmailID'])),
                    DataCell(Text(item['Gender'])),
                    DataCell(Text(item['DOB'])),
                    DataCell(Text(item['PhoneNumber'].toString())),
                    DataCell(Text(item['SSN'].toString())),
                    DataCell(Text(item['StreetAddress'].toString())),
                    DataCell(Text(item['City'].toString())),
                    DataCell(Text(item['State'].toString())),
                    DataCell(Text(item['CreditCardNumber'].toString())),
                    DataCell(Text(item['CVV'].toString())),
                    DataCell(Text(item['DriverLicenseNumber'].toString())),
                  ],
                ),
              )
                  .toList(),
            )
                : Center(
              child: Text('No data available.'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_currentPage > 1) {
                      setState(() {
                        _currentPage--;
                        _getData();
                      });
                    }
                  },
                ),
                Text('Page $_currentPage'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                      _getData();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
