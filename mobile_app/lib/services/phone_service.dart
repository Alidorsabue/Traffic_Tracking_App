import 'package:shared_preferences/shared_preferences.dart';

class PhoneService {
  static const String _phoneKey = 'user_phone_number';

  /// Récupère le numéro de téléphone stocké
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Sauvegarde le numéro de téléphone
  static Future<bool> savePhoneNumber(String phoneNumber) async {
    // Nettoyer le numéro (enlever espaces, tirets, etc.)
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Valider que c'est bien 10 chiffres
    if (cleanPhone.length != 10) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_phoneKey, cleanPhone);
  }

  /// Valide qu'un numéro de téléphone a exactement 10 chiffres
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 10;
  }

  /// Formate le numéro de téléphone pour l'affichage (XX XX XX XX XX)
  static String formatPhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length != 10) return phoneNumber;
    return '${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 4)} ${cleanPhone.substring(4, 6)} ${cleanPhone.substring(6, 8)} ${cleanPhone.substring(8, 10)}';
  }
}

