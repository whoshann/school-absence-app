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

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      print('Mencoba login dengan username: ${_usernameController.text}');

      final response = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      print('Response login: ${response.toString()}');

      if (response.success) {
        print('Login berhasil! Token: ${response.data.accessToken}');

        // Simpan token
        await _saveToken(response.data.accessToken);

        // Verifikasi token tersimpan
        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString('access_token');
        print('Token tersimpan: $savedToken');

        Get.offAll(() => HomeScreen());
      } else {
        print('Login gagal: ${response.code}');
        Get.snackbar(
          'Error',
          'Login gagal',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error during login: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text "Sis" di atas logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Text(
                      "Sis",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(44, 44, 44, 1),
                      ),
                    ),
                  ),

                  // Logo
                  Image.asset('assets/images/school-management-website.png',
                      width: 200, height: 200),
                  SizedBox(height: 20),

                  // Selamat Datang Kembali
                  Column(
                    children: [
                      Text(
                        'Selamat Datang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(44, 44, 44, 1),
                        ),
                      ),
                      Text(
                        'Kembali!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(44, 44, 44, 1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),

                  // Input Username
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan NIS',
                      filled: true,
                      fillColor: Color.fromRGBO(240, 240, 240, 1),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(31, 80, 154, 1), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 35),

                  // Input Password
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Masukkan Password',
                      filled: true,
                      fillColor: Color.fromRGBO(240, 240, 240, 1),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(31, 80, 154, 1), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2),
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
                  SizedBox(height: 35),

                  // Button Masuk
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: const Color.fromRGBO(31, 80, 154, 1),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Masuk',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20, color: Colors.white),
                            ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
