import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2), () {});
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => NoteListPage()), // NoteListPage sınıfını kullanıyoruz
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Ana ekranın arka plan rengi ile aynı yapıldı
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Güncellenmiş logo dosyasının yolunu belirtin
          width: 200, // Logonun boyutunu büyütmek için genişlik ve yükseklik ayarlandı
          height: 200,
        ),
      ),
    );
  }
}
