// import 'package:flutter/material.dart';
// import 'auth/sign_up_screen.dart';

// void main() {
//   runApp(const MyHome());
// }

// class MyHome extends StatelessWidget {
//   const MyHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My Home',
//       debugShowCheckedModeBanner: false,
//       home: const SignUpScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
// import 'auth/sign_in_screen.dart';
// import 'devices/devices-control-screen.dart';
import 'devices/main_navigation.dart';
void main() {
  runApp(const MyHome());
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Home',
      debugShowCheckedModeBanner: false,
      // home: const DeviceControlScreen (),
      home: const MainNavigation(), 
    );
  }
}