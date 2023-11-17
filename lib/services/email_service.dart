import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<bool> sendEmail(String toEmail, String username, String password) async {
    final smtpServer = gmail('renukrish18@gmail.com', 'Amitavikramaah%36');

    final message = Message()
      ..from = Address('renukrish18@gmail.com', 'Renuga')
      ..recipients.add(toEmail)
      ..subject = 'Registration Successful'
      ..text = 'Hello $username,\n\nYour account has been successfully registered.\n\nUsername: $username\nPassword: $password';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}
