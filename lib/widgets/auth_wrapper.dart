import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../screens/login_screen.dart';
import '../tabs/home_tabs.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthsProvider>(context);

    if (authProvider.user == null) {
      return LoginScreen();
    } else {
      return HomeScreen();
    }
  }
}
