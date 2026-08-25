
import 'package:flutter/foundation.dart';
import '../api/api_config.dart';
import '../api/api_default.dart';
import '../api/api_status.dart';
import '../model/home/infos_accueil.dart';
import '../model/home/infos_response.dart';

class HomeService {
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();



  Future<InfosAccueil?> loadHomeData() async {
    return _loadHomeData();
  }

  Future<InfosAccueil?> _loadHomeData() async {
    try {
      final response = await ApiDefault.postData(ApiConfig.agentStart, {
        'to_identifiant': '',
      });
      final infosResponse = InfosResponse.fromJson(response);

      if (infosResponse.isSuccess && infosResponse.information != null) {
        return infosResponse.information;
      } else if (ApiStatus.isSuccess(response['status'])) {
        return InfosAccueil.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('HomeService _loadHomeData error: $e');
      return null;
    }
  }
}
