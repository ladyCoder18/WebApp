import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/userdata.dart';
import '../services/database_helper.dart';

class DisplayAndEditDetailsPage extends StatefulWidget {
  @override
  _DisplayAndEditDetailsPageState createState() => _DisplayAndEditDetailsPageState();
}

class _DisplayAndEditDetailsPageState extends State<DisplayAndEditDetailsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data Table'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('First Name')),
            DataColumn(label: Text('Last Name')),
            DataColumn(label: Text('Email')),
            // Add more DataColumn widgets for other fields as needed
          ],
          rows: _userData
              .map(
                (user) => DataRow(
              selected: false, // Set selected to true for rows that should be selected
              onSelectChanged: (selected) {
                // Implement logic to handle row selection
              },
              cells: [
                DataCell(Text(user.firstName)),
                DataCell(Text(user.lastName)),
                DataCell(Text(user.emailId)),
                // Add more DataCell widgets for other fields as needed
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
