import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import 'login_page.dart';

class DisplayDetailsPage extends StatefulWidget {
  @override
  _DisplayDetailsPageState createState() => _DisplayDetailsPageState();
}

class _DisplayDetailsPageState extends State<DisplayDetailsPage> {
  TextEditingController _queryController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  List<String> _queryTypes = ['Name', 'From Date', 'Date Range'];
  String _selectedQueryType = 'Name';
  DateTime? _selectedDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<Map<String, dynamic>> _data = [];
  int _currentPage = 1;
  int _pageSize = 10;

  Future<void> _getData() async {
    String query = _queryController.text;
    if (_selectedQueryType == 'Name') {
      List<Map<String, dynamic>> data =
          await DatabaseHelper.instance.getPagedDataByName(query);
      _updateData(data);
    } else if (_selectedQueryType == 'From Date' && _selectedDate != null) {
      List<Map<String, dynamic>> data = await DatabaseHelper.instance
          .getPagedDataByDate(_selectedDate!, _currentPage, _pageSize);
      _updateData(data);
    } else if (_selectedQueryType == 'Date Range' &&
        _selectedStartDate != null &&
        _selectedEndDate != null) {
      List<Map<String, dynamic>> data = await DatabaseHelper.instance
          .getPagedDataByDateRange(
          _selectedStartDate!, _selectedEndDate!, _currentPage, _pageSize);
      _updateData(data);
    }
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Function to show date picker for date range
  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2101),
    );

    setState(() {
      _selectedStartDate = pickedStartDate;
      _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedStartDate!);
    });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_selectedStartDate != null) {
      DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _selectedEndDate ?? _selectedStartDate!,
        firstDate: _selectedStartDate!,
        lastDate: DateTime(2101),
      );

      setState(() {
        _selectedEndDate = pickedEndDate;
        _endDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedEndDate!);
      });
    }
  }

  void _updateData(List<Map<String, dynamic>> data) {
    setState(() {
      _data = data;
    });

    // Clear the contents
    _queryController.clear();
    _dateController.clear();
    _startDateController.clear();
    _endDateController.clear();
  }

  Future<void> _exportToCSV() async {
    // Generate CSV data from _data list
    String csvData =
        'FirstName, LastName, EmailId, Gender, DOB, PhoneNumber, SSN, Address, City, State, CreditCardNumber,CVV, DriverLicenseNumber\n';
    for (var item in _data) {
      csvData += '${item['firstName']},'
          ' ${item['lastName']},'
          ' ${item['emailId']},'
          ' ${item['gender']},'
          ' ${item['dateOfBirth:']},'
          ' ${item['phoneNumber']},'
          ' ${item['ssn']},'
          ' ${item['address']},'
          ' ${item['city']},'
          ' ${item['state']},'
          ' ${item['creditCardNumber']},'
          ' ${item['cvv']},'
          ' ${item['driverLicenseNumber']}\n'; // Update with actual field names
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

    Widget _getCellValue(dynamic value) {
      return value != null && value.toString().isNotEmpty
          ? Icon(Icons.check, color: Colors.green)
          : Icon(Icons.close_sharp, color: Colors.red);
    }

    Widget dataWidget = _data.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
                rows: _data
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item['firstName'])),
                          DataCell(Text(item['lastName'] ?? 'N/A')),
                          DataCell(Text(item['emailId'] ?? 'N/A')),
                          DataCell(Text(item['phoneNumber'].toString())),
                          DataCell(_getCellValue(item[
                              'dateOfBirth'])), // Show check mark if not null
                          DataCell(_getCellValue(
                              item['ssn'])),
                          DataCell(_getCellValue(item['address'])),
                          DataCell(_getCellValue(item[
                              'creditCardNumber'])),
                          DataCell(_getCellValue(item[
                              'driverLicenseNumber'])),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
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
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              value: _selectedQueryType,
              onChanged: (newValue) {
                setState(() {
                  _selectedQueryType = newValue!;
                });
              },
              items: _queryTypes.map<DropdownMenuItem<String>>((queryType) {
                return DropdownMenuItem<String>(
                  value: queryType,
                  child: Text(queryType),
                );
              }).toList(),
            ),
            if (_selectedQueryType == 'From Date') ...[
              SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDateFrom(context),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                    ),
                  ),
                ),
              ),
            ] else if (_selectedQueryType == 'Date Range') ...[
              SizedBox(height: 20),
              InkWell(
                onTap: () => _selectStartDate(context),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () => _selectEndDate(context),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: 20),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: 'Enter Name',
                ),
              ),
            ],
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _getData();
                  },
                  child: Text('Get Data'),
                ),
                SizedBox(width: 10), // Add some space between the buttons
                exportButton,
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: dataWidget,
              ),
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
