class LoginResponse {
  final bool success;
  final String code;
  final TokenData data;

  LoginResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      code: json['code'],
      data: TokenData.fromJson(json['data']),
    );
  }
}

class TokenData {
  final String accessToken;

  TokenData({required this.accessToken});

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['access_token'],
    );
  }
}
