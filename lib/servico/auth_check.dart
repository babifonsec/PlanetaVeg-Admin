import 'package:flutter/material.dart';
import 'package:pvadmin/servico/auth_service.dart';
import 'package:pvadmin/visao/home.dart';
import 'package:pvadmin/visao/login.dart';
import 'package:pvadmin/visao/splash.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of(context);

    if(auth.isLoading) return Splash();
    else if(auth.usuario==null) return Login();
    else return Home();
  }
}
