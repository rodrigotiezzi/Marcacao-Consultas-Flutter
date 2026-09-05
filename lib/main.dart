import 'package:flutter/material.dart';

import 'src/models/models.dart';
import 'src/routes/app_routes.dart';
import 'src/screens/screens.dart';
import 'src/styles/app_colors.dart';

void main() {
 runApp(const MarcacaoConsultasApp());
}

class MarcacaoConsultasApp extends StatelessWidget {
 const MarcacaoConsultasApp({super.key});

 @override
 Widget build(BuildContext context) {
 return MaterialApp(
 debugShowCheckedModeBanner: false,
 title: 'Sistema de Consultas',
 theme: ThemeData(
 colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaria),
 useMaterial3: true,
 ),
 initialRoute: AppRoutes.home,
 routes: {
 AppRoutes.home: (_) => const HomeScreen(),
 AppRoutes.admin: (_) => const AdminScreen(),
 },
 onGenerateRoute: (settings) {
 if (settings.name == AppRoutes.detalhe) {
 final consulta = settings.arguments;
 if (consulta is! Consulta) {
 return MaterialPageRoute(
 builder: (_) => const HomeScreen(),
 settings: settings,
 );
 }
 return MaterialPageRoute(
 builder: (_) => DetalheConsultaScreen(consulta: consulta),
 settings: settings,
 );
 }
 return null;
 },
 );
 }
}
