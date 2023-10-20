class UserData{

  final String firstName;
  final String lastName;
  final String emailId;
  final String gender;
  final String dateOfBirth;
  final String phoneNumber;
  final String ssn;
  final String streetAddress;
  final String city;
  final String state;
  final String creditCardNumber;
  final String cvv;
  final String driverLicenseNumber;


  UserData({
    required this.firstName,
    required this.lastName,
    required this.emailId,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.ssn,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.creditCardNumber,
    required this.cvv,
    required this.driverLicenseNumber});

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'emailId': emailId,
      'gender': gender,
      'dateOfBirth' : dateOfBirth,
      'phoneNumber' : phoneNumber,
      'ssn' : ssn,
      'streetAddress' : streetAddress,
      'city' : city,
      'state' : state,
      'creditCardNumber' : creditCardNumber,
      'cvv': cvv,
      'driverLicenseNumber': driverLicenseNumber
    };
  }
}