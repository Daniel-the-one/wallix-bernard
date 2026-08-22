// lib/api/api_config.dart

class ApiConfig {
  static const String baseUrl = "https://cygne.mdkrlabs.dev/api/web/v1";

  // 10 Endpoints observés dans l'APK Wallix
  static const String agentStart = "agents/start";
  static const String agentOperations = "agents/operations";
  static const String agentDepot = "agents/depot";
  static const String agentInitRetrait = "agents/init_retrait";
  static const String agentCancelRetrait = "agents/cancel_retrait";
  static const String agentAllCommission = "agents/all_commission";
  static const String agentAllRetrait = "agents/all_retrait";
  static const String contactsCheckQr = "contacts/check_qr";
  static const String usersConnecteUseraccount = "users/connecte_useraccount";
  static const String usersUpdatePassword = "users/update_password";

  // Aliases & helpers
  static const String homeStart = agentStart;
  static const String allRetraits = agentAllRetrait;
  static const String cancelRetrait = agentCancelRetrait;
  static const String executeDepot = agentDepot;
  static const String initRetrait = agentInitRetrait;
  static const String allCommission = agentAllCommission;
  static const String operations = agentOperations;
  static const String checkQr = contactsCheckQr;
  static const String connecteUser = usersConnecteUseraccount;
  static const String updatePassword = usersUpdatePassword;

  // Timeouts & headers
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
