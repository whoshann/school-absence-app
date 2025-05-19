class LoginResponse {
  final bool success;
  final String code;
  final TokenData? data;

  LoginResponse({
    required this.success,
    required this.code,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    bool successValue = json['success'] == true;
    String codeValue = json['code']?.toString() ?? 'unknown';
    TokenData? dataValue;

    if (json['data'] != null &&
        json['data'] is Map<String, dynamic> &&
        json['data']['access_token'] != null) {
      dataValue = TokenData.fromJson(json['data']);
    }

    return LoginResponse(
      success: successValue,
      code: codeValue,
      data: dataValue,
    );
  }
}

class TokenData {
  final String accessToken;

  TokenData({required this.accessToken});

  factory TokenData.fromJson(Map<String, dynamic> json) {
    String token = json['access_token']?.toString() ?? '';
    return TokenData(
      accessToken: token,
    );
  }
}
