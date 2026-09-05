import 'package:flutter/material.dart';

import 'src/data/storage.dart';
import 'src/models/models.dart';
import 'src/routes/app_routes.dart';
import 'src/screens/screens.dart';
import 'src/styles/app_colors.dart';

void main() {
  runApp(const MarcacaoConsultasApp());
}

class MarcacaoConsultasApp extends StatefulWidget {
  const MarcacaoConsultasApp({super.key});

  @override
  State<MarcacaoConsultasApp> createState() => _MarcacaoConsultasAppState();
}

class _MarcacaoConsultasAppState extends State<MarcacaoConsultasApp> {
  bool _pronto = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await Storage.inicializarDados();
    if (mounted) {
      setState(() => _pronto = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(_pronto),
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Consultas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaria),
        useMaterial3: true,
      ),
      navigatorObservers: [appRouteObserver],
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) =>
            _pronto ? const LoginScreen() : const _TelaInicializacao(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.agendamento: (_) => const AgendamentoScreen(),
        AppRoutes.admin: (_) => const AdminScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.detalhe) {
          final consulta = settings.arguments;
          if (consulta is! Consulta) {
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
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

class _TelaInicializacao extends StatelessWidget {
  const _TelaInicializacao();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaria,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.branco),
      ),
    );
  }
}


