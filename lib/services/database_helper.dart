import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/userdata.dart';

class DatabaseHelper {
  static final _databaseName = 'webapp_database.db';
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      //onUpgrade: _onUpgrade
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT,
        canRead INTEGER, 
        canWrite INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE userData(
      firstName TEXT,
      lastName TEXT,
      emailId TEXT,
      gender TEXT,
      dateOfBirth TEXT,
      phoneNumber TEXT,
      ssn TEXT,
      streetAddress TEXT,
      city TEXT,
      state TEXT,
      creditCardNumber TEXT,
      cvv TEXT,
      driverLicenseNumber TEXT
    )
    ''');
  }

  /*Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      // Perform schema changes for version 2 (and subsequent versions, if needed).
      await db.execute('ALTER TABLE users ADD COLUMN new_column TEXT;');
    }
    // Add more conditions for other version upgrades if necessary.
  }*/

  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<int> insertData(UserData data) async {
    Database db = await instance.database;
    return await db.insert('userData', data.toMap());
  }

  Future<User?> getUserByUsernameAndPassword(String username, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query('users', where: 'username = ? and password = ?', whereArgs: [username, password]);
    if (results.isEmpty) return null;
    return User(
      id: results[0]['id'],
      username: results[0]['username'],
      password: results[0]['password'],
      canRead: results[0]['canRead'] == 1 ? true : false,
      canWrite: results[0]['canWrite'] == 1 ? true : false
    );
  }

  Future<List<Map<String, dynamic>>> getPagedData(String dateOfBirth, int page, int pageSize) async {
    Database db = await instance.database;
    int offset = (page - 1) * pageSize;

    // SQLite query to retrieve paged data based on date and name
    String query = '''
      SELECT * FROM userData
      WHERE dateOfBirth = ?
      LIMIT $pageSize OFFSET $offset
    ''';

    // Replace date_column and name_column with actual column names in your 'data' table
    // Pass date and name as arguments to the query
    List<Map<String, dynamic>> result = await db.rawQuery(query, [dateOfBirth]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getPagedDataByName(String firstName) async {
    Database db = await instance.database;

    // SQLite query to retrieve paged data based on firstName
    String query = '''
    SELECT * FROM userData
    WHERE firstName = ?
  ''';

    // Pass firstName as an argument to the query
    List<Map<String, dynamic>> result = await db.rawQuery(query, [firstName]);

    print(result);

    return result;
  }


  Future<void> updateUserPermissions(String userName, bool canRead, bool canWrite) async {
    Database db = await instance.database;

    // Assuming your users table has columns named 'id', 'canRead', and 'canWrite'
    await db.update(
      'users',
      {
        'canRead': canRead ? 1 : 0, // Store boolean as 1 for true, 0 for false
        'canWrite': canWrite ? 1 : 0,
      },
      where: 'userName = ?',
      whereArgs: [userName],
    );
  }

  Future<void> updateData(int? id, UserData data) async {
    Database db = await instance.database;

    // Assuming your users table has columns named 'id', 'canRead', and 'canWrite'
    await db.update(
      'userData',
      {
        'firstName' : data.firstName,
        'lastName' : data.lastName,
        'gender' : data.gender,
        'emailId' : data.emailId,
        'phoneNumber' : data.phoneNumber,
        'ssn' : data.ssn,
        'streetAddress' : data.streetAddress,
        'city' : data.city,
        'state' : data.state,
        'creditCardNumber' : data.creditCardNumber,
        'cvv' : data.cvv,
        'driverLicenseNumber' : data.driverLicenseNumber,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<User>> getAllUsers() async {
    Database db = await instance.database;

    // Assuming your User class has properties: id, username, canRead, and canWrite
    List<Map<String, dynamic>> result = await db.query('users');

    // Convert the List<Map<String, dynamic>> to List<User>
    List<User> users = [];
    for (Map<String, dynamic> row in result) {
      users.add(User(
        id: row['id'],
        username: row['username'],
        password: row['password'],
        canRead: row['canRead'] == 1, // Convert 1 to true, 0 to false
        canWrite: row['canWrite'] == 1,
      ));
    }

    return users;
  }

  Future<List<UserData>> getAllData() async {
    Database db = await instance.database;

    // Assuming your User class has properties: id, username, canRead, and canWrite
    List<Map<String, dynamic>> result = await db.query('userData');

    // Convert the List<Map<String, dynamic>> to List<User>
    List<UserData> data = [];
    for (Map<String, dynamic> row in result) {
      data.add(UserData(
          firstName: row['firstName'],
          lastName: row['lastName'],
          emailId: row['emailId'],
          gender: row['gender'],
          dateOfBirth: row['dateOfBirth'],
          phoneNumber: row['phoneNumber'],
          ssn: row['ssn'],
          streetAddress: row['streetAddress'],
          city: row['city'],
          state: row['state'],
          creditCardNumber: row['creditCardNumber'],
          cvv: row['cvv'],
          driverLicenseNumber: row['driverLicenseNumber']
      ));
    }
    return data;
  }

  /*Future<UserData> checkIfDataExistsWithEmailId(String emailId) async{
    Database db = await instance.database;

    // SQLite query to retrieve paged data based on date and name
    String query = '''
      SELECT * FROM userData
      WHERE emailId = ? 
      ORDER BY id DESC
    ''';

    // Replace date_column and name_column with actual column names in your 'data' table
    // Pass date and name as arguments to the query
    List<Map<String, dynamic>> result = await db.query('userData');

    if (result.isEmpty) return null;
    return result[0];
  }*/
}