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

class _HomeScreenState extends State<HomeScreen> {
 List<Consulta> _consultas = [];
 bool _carregando = true;

 @override
 void initState() {
 super.initState();
 _carregarConsultas();
 }

 Future<void> _carregarConsultas() async {
 final consultas = await Storage.obterConsultas();
 if (!mounted) {
 return;
 }
 setState(() {
 _consultas = consultas;
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
 setState(() {
 _consultas = _consultas
 .map(
 (consulta) => consulta.id == id
 ? consulta.copyWith(status: status)
 : consulta,
 )
 .toList();
 });
 await Storage.salvarConsultas(_consultas);
 }

 Future<void> _abrirAdmin() async {
 await Navigator.pushNamed(context, AppRoutes.admin);
 await _carregarConsultas();
 }

 void _abrirDetalhes(int id) {
 final consulta = _consultas.firstWhere((item) => item.id == id);
 Navigator.pushNamed(context, AppRoutes.detalhe, arguments: consulta);
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
 actions: [
 IconButton(
 tooltip: 'Painel administrativo',
 onPressed: _abrirAdmin,
 icon: const Icon(Icons.admin_panel_settings_outlined),
 ),
 ],
 ),
 body: SafeArea(
 child: Column(
 children: [
 Padding(
 padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
 child: Text(
 '${_consultas.length} consulta(s) agendada(s)',
 textAlign: TextAlign.center,
 style: const TextStyle(color: AppColors.branco, fontSize: 16),
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
 return _EstadoVazio(onAbrirAdmin: _abrirAdmin);
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

class _EstadoVazio extends StatelessWidget {
 const _EstadoVazio({required this.onAbrirAdmin});

 final VoidCallback onAbrirAdmin;

 @override
 Widget build(BuildContext context) {
 return Padding(
 padding: const EdgeInsets.all(24),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Text(
 'Nenhuma consulta agendada ainda',
 textAlign: TextAlign.center,
 style: TextStyle(color: AppColors.branco, fontSize: 16),
 ),
 const SizedBox(height: 20),
 ElevatedButton(
 onPressed: onAbrirAdmin,
 style: ElevatedButton.styleFrom(
 backgroundColor: AppColors.branco,
 foregroundColor: AppColors.primaria,
 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
 ),
 child: const Text('Ir para Admin'),
 ),
 ],
 ),
 );
 }
}
