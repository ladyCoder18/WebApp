class User {
  final int? id;
  final String username;
  final String password;
  final String emailId;
  final bool canWrite;

  User(
      {this.id,
      required this.username,
      required this.password,
      required this.emailId,
      this.canWrite = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'emailId' : emailId,
      'canWrite': canWrite
    };
  }
}
