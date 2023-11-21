class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String password;
  final String userId;
  final String emailId;
  final bool canWrite;

  User(
      {this.id,
      required this.firstName,
      required this.lastName,
      required this.password,
      required this.userId,
      required this.emailId,
      this.canWrite = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'userId': userId,
      'emailId' : emailId,
      'canWrite': canWrite
    };
  }
}
