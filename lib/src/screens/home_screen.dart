import 'package:flutter/material.dart';

import '../components/components.dart';
import '../data/storage.dart';
import '../models/models.dart';
import '../routes/app_routes.dart';
import '../styles/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<Consulta> _consultas = [];
  String _nomePaciente = '';
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rota = ModalRoute.of(context);
    if (rota != null) {
      appRouteObserver.subscribe(this, rota);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final paciente = await Storage.obterPacienteLogado();
    if (!mounted) {
      return;
    }
    if (paciente == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final todas = await Storage.obterConsultas();
    final doPaciente = todas
        .where((consulta) => consulta.paciente.id == paciente.id)
        .toList();

    if (!mounted) {
      return;
    }
    setState(() {
      _nomePaciente = paciente.nome;
      _consultas = doPaciente;
      _carregando = false;
    });
  }

  Future<void> _confirmarConsulta(int id) async {
    await _atualizarStatus(id, StatusConsulta.confirmada);
  }

  Future<void> _cancelarConsulta(int id) async {
    await _atualizarStatus(id, StatusConsulta.cancelada);
  }

  Future<void> _atualizarStatus(int id, StatusConsulta status) async {
    final paciente = await Storage.obterPacienteLogado();
    final todas = await Storage.obterConsultas();
    final atualizadas = todas
        .map(
          (consulta) =>
              consulta.id == id ? consulta.copyWith(status: status) : consulta,
        )
        .toList();
    await Storage.salvarConsultas(atualizadas);

    if (!mounted || paciente == null) {
      return;
    }
    setState(() {
      _consultas = atualizadas
          .where((consulta) => consulta.paciente.id == paciente.id)
          .toList();
    });
  }

  void _abrirDetalhes(int id) {
    final consulta = _consultas.firstWhere((item) => item.id == id);
    Navigator.pushNamed(context, AppRoutes.detalhe, arguments: consulta);
  }

  Future<void> _abrirAgendamento() async {
    await Navigator.pushNamed(context, AppRoutes.agendamento);
    await _carregarDados();
  }

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo, true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }
    await Storage.removerPacienteLogado();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaria,
      appBar: AppBar(
        backgroundColor: AppColors.primaria,
        foregroundColor: AppColors.branco,
        elevation: 0,
        title: const Text('Minhas Consultas'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  Text(
                    _nomePaciente.isEmpty ? 'Olá!' : 'Olá, $_nomePaciente!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.branco,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_consultas.length} consulta(s) agendada(s)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.branco,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _abrirAgendamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sucesso,
                      foregroundColor: AppColors.branco,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('+ Agendar Nova Consulta'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _sair,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.branco,
                      side: const BorderSide(color: AppColors.branco),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Sair'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: _corpo),
          ],
        ),
      ),
    );
  }

  Widget get _corpo {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.branco),
      );
    }
    if (_consultas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, color: AppColors.branco, size: 48),
            SizedBox(height: 16),
            Text(
              'Você ainda não tem consultas agendadas',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.branco, fontSize: 18),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _consultas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final consulta = _consultas[index];
        return ConsultaCard(
          key: ValueKey(consulta.id),
          consulta: consulta,
          onConfirmar: _confirmarConsulta,
          onCancelar: _cancelarConsulta,
          onVerDetalhes: _abrirDetalhes,
        );
      },
    );
  }
}


