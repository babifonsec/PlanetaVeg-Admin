import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:pvadmin/controle/LojaController.dart';
import 'package:pvadmin/controle/ProdutoController.dart';
import 'package:pvadmin/controle/PromocaoController.dart';
import 'package:pvadmin/servico/auth_check.dart';
import 'firebase_options.dart'; 
import 'package:pvadmin/servico/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider<ProdutoController>(
          create: (context) => ProdutoController(),
        ),
        ChangeNotifierProvider<LojaController>(
          create: (context) => LojaController(),
        ),
        ChangeNotifierProvider<PromocaoController>(
          create: (context) => PromocaoController(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    );
  }
}
