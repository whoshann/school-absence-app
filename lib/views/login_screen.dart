import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_absence/views/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_absence/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<void> _handleLogin() async {
    // Validasi input terlebih dahulu
    if (_usernameController.text.isEmpty) {
      _showErrorMessage('NIS tidak boleh kosong', 'Silakan masukkan NIS Anda');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorMessage(
          'Password tidak boleh kosong', 'Silakan masukkan password Anda');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Hapus token yang mungkin tersimpan sebelumnya
      await _clearToken();

      final response = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (response.success == true &&
          response.data != null &&
          response.data!.accessToken.isNotEmpty) {
        // Simpan token
        await _saveToken(response.data!.accessToken);
        Get.offAll(() => HomeScreen());
      } else {
        // Pesan yang lebih spesifik berdasarkan kode respons
        if (response.code == 'USERNAME_NOT_FOUND') {
          _showErrorMessage('NIS Tidak Ditemukan',
              'NIS yang Anda masukkan tidak terdaftar dalam sistem');
        } else if (response.code == 'INVALID_PASSWORD') {
          _showErrorMessage(
              'Password Salah', 'Password yang Anda masukkan salah');
        } else {
          _showErrorMessage(
              'Login Gagal', 'NIS atau password yang Anda masukkan salah');
        }
      }
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('NIS') ||
          errorMessage.contains('username') ||
          errorMessage.contains('tidak ditemukan')) {
        _showErrorMessage('NIS Tidak Ditemukan',
            'NIS yang Anda masukkan tidak terdaftar dalam sistem');
      } else if (errorMessage.contains('password') ||
          errorMessage.contains('sandi')) {
        _showErrorMessage(
            'Password Salah', 'Password yang Anda masukkan salah');
      } else if (errorMessage.contains('connection') ||
          errorMessage.toLowerCase().contains('network') ||
          errorMessage.toLowerCase().contains('socket')) {
        _showErrorMessage('Koneksi Gagal',
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi');
      } else {
        _showErrorMessage(
            'Terjadi Kesalahan', errorMessage.replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red[700],
      colorText: Colors.white,
      margin: EdgeInsets.all(10),
      borderRadius: 10,
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Cek apakah ada arguments (pesan error)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is String) {
        final message = Get.arguments as String;
        Get.snackbar(
          'Peringatan',
          message,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          margin: EdgeInsets.all(10),
        );
      }
    });

    // Hapus token lama saat halaman login dibuka
    _clearToken();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final Size screenSize = MediaQuery.of(context).size;
    // Tentukan apakah layar kecil
    final bool isSmallScreen = screenSize.width < 380;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20.0 : 30.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text "Sis" di atas logo
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: isSmallScreen ? 30 : 60,
                        top: isSmallScreen ? 20 : 30,
                      ),
                      child: Text(
                        "Sis",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(44, 44, 44, 1),
                        ),
                      ),
                    ),

                    // Logo
                    Image.asset(
                      'assets/images/school-management-website.png',
                      width: isSmallScreen ? 150 : 200,
                      height: isSmallScreen ? 150 : 200,
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),

                    // Selamat Datang Kembali
                    Column(
                      children: [
                        Text(
                          'Selamat Datang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 28 : 40,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(44, 44, 44, 1),
                          ),
                        ),
                        Text(
                          'Kembali!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 28 : 40,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(44, 44, 44, 1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 50),

                    // Input Username
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Masukkan NIS',
                        filled: true,
                        fillColor: Color.fromRGBO(240, 240, 240, 1),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 18,
                          horizontal: 16,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(31, 80, 154, 1),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 35),

                    // Input Password
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Masukkan Password',
                        filled: true,
                        fillColor: Color.fromRGBO(240, 240, 240, 1),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 18,
                          horizontal: 16,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(31, 80, 154, 1),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 25 : 35),

                    // Button Masuk
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14 : 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          backgroundColor: const Color.fromRGBO(31, 80, 154, 1),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
