class User {
  final int? id;
  final String username;
  final String password;
  final bool canRead;
  final bool canWrite;

  User({this.id, required this.username, required this.password, this.canRead = false, this.canWrite = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'canRead' : canRead,
      'canWrite' : canWrite
    };
  }
}
