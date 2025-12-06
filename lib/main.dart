import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/clientes_list_screen.dart';
import 'screens/produtos_list_screen.dart';

void main() {
  runApp(const DesafioFinalApp());
}

class DesafioFinalApp extends StatelessWidget {
  const DesafioFinalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio Final',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (ctx) => const LoginScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/clientes': (ctx) => const ClientesListScreen(),
        '/produtos': (ctx) => const ProdutosListScreen(),
      },
    );
  }
}
