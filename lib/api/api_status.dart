

class ApiStatus {
  static const String success = '000';

  static bool isSuccess(dynamic status) {
    final String? s = status?.toString();
    return s == success || s == 'success';
  }
}
