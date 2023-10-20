import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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

    //Clear the contents
    dateController.clear();
    nameController.clear();
  }

  Future<void> _getDataByName() async {
    String name = nameController.text;
    print('Name'+ name);
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.getPagedDataByName(name);
    setState(() {
      _data = data;
    });

    print("object");
    print(_data);
    //Clear the contents
    dateController.clear();
    nameController.clear();
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
          ' ${item['city']},'
          ' ${item['state']},'
          ' ${item['creditCardNumber']},'
          ' ${item['cvv']},'
          ' ${item['drivingLicenseNumber']}\n'; // Update with actual field names
    }

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.csv');

    // Write the CSV data to the file
    await file.writeAsString(csvData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('CSV file exported to ${file.path}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    User? user; // Make User nullable to handle potential null values

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      // Handle null check and type cast here
      if (ModalRoute.of(context)?.settings.arguments != null) {
        user = ModalRoute.of(context)!.settings.arguments as User?;
      }
    }

    Widget dataWidget = _data.isNotEmpty
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
            DataCell(Text(item['firstName'] ?? 'N/A')),
            DataCell(Text(item['lastName']?? 'N/A')),
            DataCell(Text(item['emailID'] ?? 'N/A')),
            DataCell(Text(item['gender'] ?? 'N/A')),
            DataCell(Text(item['dob'] ?? 'N/A')),
            DataCell(Text(item['phoneNumber'].toString())),
            DataCell(Text(item['ssn'].toString())),
            DataCell(Text(item['streetAddress'].toString())),
            DataCell(Text(item['city'].toString())),
            DataCell(Text(item['state'].toString())),
            DataCell(Text(item['creditCardNumber'].toString())),
            DataCell(Text(item['cvv'].toString())),
            DataCell(Text(item['driverLicenseNumber'].toString())),
          ],
        ),
      )
          .toList(),
    )
        : Center(
      child: Text('No data available.'),
    );

    Widget exportButton = _data.isNotEmpty
        ? IconButton(
      icon: Icon(Icons.file_download),
      onPressed: _exportToCSV,
    )
        : SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: Text('Display Details'),
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _getDataByName();
                  },
                  child: Text('Get Data'),
                ),
                SizedBox(width: 10), // Add some space between the buttons
                exportButton,
              ],
            ),
            SizedBox(height: 20),
            dataWidget,
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