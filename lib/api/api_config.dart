import '../env/env.g.dart';

class ApiConfig {
  static const String urlApi = 'https://cygne.mdkrlabs.dev/api/web/v1';
  static const String urlApiC = 'https://mobile.prestup.app/api/web/v1';
  static const String baseUrl = urlApi;
  static const String baseUrlC = urlApiC;

  static const String apiKey = Env.apiKey;
  static const String defaultAccessToken = Env.defaultAccessToken;
  static const String defaultCIdentifiant = Env.defaultCIdentifiant;

  static const String agentStart = "agents/start";
  static const String agentOperations = "agents/operations";
  static const String agentDepot = "agents/depot";
  static const String agentInitRetrait = "agents/init_retrait";
  static const String agentCancelRetrait = "agents/cancel_retrait";
  static const String agentAllRetrait = "agents/all_retrait";
  static const String agentAllCommission = "agents/all_commission";
  static const String contactsCheckQr = "contacts/check_qr";
  static const String operationsValidateRetrait = "operations/validate_retrait";
  static const String operationsAllRetrait = "operations/all_retrait";
  static const String operationsCancelEnvoi = "operations/cancel_envoi";
  static const String operationsSendMoney = "operations/send_money";
  static const String operationsGetFrais = "operations/get_frais";
  static const String usersConnecteUseraccount = "users/connecte_useraccount";
  static const String usersUpdatePassword = "users/update_password";
  static const String usersCreateUseraccount = "users/create_useraccount";
  static const String usersForgetPassword = "users/forget_password";

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
