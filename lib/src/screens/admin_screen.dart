import 'package:flutter/material.dart';

import '../data/storage.dart';
import '../models/models.dart';
import '../styles/styles.dart';

class AdminScreen extends StatefulWidget {
 const AdminScreen({super.key});

 @override
 State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
 final _nomeEsp = TextEditingController();
 final _descEsp = TextEditingController();
 final _nomeMed = TextEditingController();
 final _crmMed = TextEditingController();
 final _nomePac = TextEditingController();
 final _dataConsulta = TextEditingController();

 List<Especialidade> _especialidades = [];
 List<Medico> _medicos = [];

 @override
 void initState() {
 super.initState();
 _carregarDados();
 }

 @override
 void dispose() {
 _nomeEsp.dispose();
 _descEsp.dispose();
 _nomeMed.dispose();
 _crmMed.dispose();
 _nomePac.dispose();
 _dataConsulta.dispose();
 super.dispose();
 }

 Future<void> _carregarDados() async {
 final especialidades = await Storage.obterEspecialidades();
 final medicos = await Storage.obterMedicos();
 setState(() {
 _especialidades = especialidades;
 _medicos = medicos;
 });
 }

 void _mostrarErro(String mensagem) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text(mensagem), backgroundColor: AppColors.perigo),
 );
 }

 void _mostrarSucesso(String mensagem) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text(mensagem), backgroundColor: AppColors.sucesso),
 );
 }

 Future<void> _adicionarEspecialidade() async {
 final nome = _nomeEsp.text.trim();
 final descricao = _descEsp.text.trim();
 if (nome.isEmpty || descricao.isEmpty) {
 _mostrarErro('Preencha nome e descrição');
 return;
 }

 final nova = Especialidade(
 id: _especialidades.length + 1,
 nome: nome,
 descricao: descricao,
 );
 final lista = [..._especialidades, nova];
 setState(() => _especialidades = lista);
 await Storage.salvarEspecialidades(lista);
 _nomeEsp.clear();
 _descEsp.clear();
 _mostrarSucesso('Especialidade adicionada!');
 }

 Future<void> _adicionarMedico() async {
 final nome = _nomeMed.text.trim();
 final crm = _crmMed.text.trim();
 if (nome.isEmpty || crm.isEmpty) {
 _mostrarErro('Preencha nome e CRM');
 return;
 }
 if (_especialidades.isEmpty) {
 _mostrarErro('Adicione uma especialidade primeiro!');
 return;
 }

 final novo = Medico(
 id: _medicos.length + 1,
 nome: nome,
 crm: crm,
 especialidade: _especialidades.first,
 ativo: true,
 );
 final lista = [..._medicos, novo];
 setState(() => _medicos = lista);
 await Storage.salvarMedicos(lista);
 _nomeMed.clear();
 _crmMed.clear();
 _mostrarSucesso('Médico adicionado!');
 }

 DateTime? _parseData(String texto) {
 final partes = texto.split('/');
 if (partes.length != 3) {
 return null;
 }
 final dia = int.tryParse(partes[0]);
 final mes = int.tryParse(partes[1]);
 final ano = int.tryParse(partes[2]);
 if (dia == null || mes == null || ano == null) {
 return null;
 }
 return DateTime(ano, mes, dia);
 }

 Future<void> _criarConsultaTeste() async {
 final nomePaciente = _nomePac.text.trim();
 final dataTexto = _dataConsulta.text.trim();
 if (nomePaciente.isEmpty || dataTexto.isEmpty) {
 _mostrarErro('Preencha nome do paciente e data');
 return;
 }
 if (_medicos.isEmpty) {
 _mostrarErro('Adicione um médico primeiro!');
 return;
 }

 final data = _parseData(dataTexto);
 if (data == null) {
 _mostrarErro('Use a data no formato DD/MM/AAAA');
 return;
 }

 final paciente = Paciente(
 id: DateTime.now().millisecondsSinceEpoch,
 nome: nomePaciente,
 cpf: '123.456.789-00',
 email: 'paciente@email.com',
 telefone: '(11) 98765-4321',
 );

 final novaConsulta = Consulta(
 id: DateTime.now().millisecondsSinceEpoch,
 medico: _medicos.first,
 paciente: paciente,
 data: data,
 valor: 350,
 status: StatusConsulta.agendada,
 observacoes: 'Consulta de teste',
 );

 final atuais = await Storage.obterConsultas();
 await Storage.salvarConsultas([...atuais, novaConsulta]);
 _nomePac.clear();
 _dataConsulta.clear();

 if (!mounted) {
 return;
 }

 await showDialog<void>(
 context: context,
 builder: (contextoDialogo) {
 return AlertDialog(
 title: const Text('Sucesso'),
 content: const Text('Consulta criada! Volte para Home'),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(contextoDialogo),
 child: const Text('OK'),
 ),
 ],
 );
 },
 );

 if (!mounted) {
 return;
 }
 Navigator.pop(context);
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 backgroundColor: AppColors.fundoTela,
 appBar: AppBar(
 backgroundColor: AppColors.primaria,
 foregroundColor: AppColors.branco,
 title: const Text('Painel Administrativo'),
 ),
 body: SafeArea(
 child: ListView(
 padding: AdminStyles.paddingTela,
 children: [
 _SecaoAdmin(
 titulo: '1. Adicionar Especialidade',
 children: [
 TextField(
 controller: _nomeEsp,
 decoration: AdminStyles.campo('Nome da especialidade'),
 ),
 const SizedBox(height: 10),
 TextField(
 controller: _descEsp,
 decoration: AdminStyles.campo('Descrição'),
 ),
 const SizedBox(height: 12),
 ElevatedButton(
 onPressed: _adicionarEspecialidade,
 style: ElevatedButton.styleFrom(
 backgroundColor: AppColors.primaria,
 foregroundColor: AppColors.branco,
 padding: const EdgeInsets.symmetric(vertical: 14),
 ),
 child: const Text('Adicionar Especialidade'),
 ),
 if (_especialidades.isNotEmpty) ...[
 const SizedBox(height: 15),
 ..._especialidades.map(
 (esp) => Padding(
 padding: const EdgeInsets.only(bottom: 8),
 child: Text(
 '• ${esp.nome} - ${esp.descricao}',
 style: AdminStyles.itemLista,
 ),
 ),
 ),
 ],
 ],
 ),
 const SizedBox(height: 20),
 _SecaoAdmin(
 titulo: '2. Adicionar Médico',
 children: [
 TextField(
 controller: _nomeMed,
 decoration: AdminStyles.campo('Nome do médico'),
 ),
 const SizedBox(height: 10),
 TextField(
 controller: _crmMed,
 decoration: AdminStyles.campo('CRM'),
 ),
 const SizedBox(height: 12),
 ElevatedButton(
 onPressed: _adicionarMedico,
 style: ElevatedButton.styleFrom(
 backgroundColor: AppColors.primaria,
 foregroundColor: AppColors.branco,
 padding: const EdgeInsets.symmetric(vertical: 14),
 ),
 child: const Text('Adicionar Médico'),
 ),
 if (_medicos.isNotEmpty) ...[
 const SizedBox(height: 15),
 ..._medicos.map(
 (med) => Padding(
 padding: const EdgeInsets.only(bottom: 8),
 child: Text(
 '• ${med.nome} (${med.crm}) - ${med.especialidade.nome}',
 style: AdminStyles.itemLista,
 ),
 ),
 ),
 ],
 ],
 ),
 const SizedBox(height: 20),
 _SecaoAdmin(
 titulo: '3. Criar Consulta de Teste',
 children: [
 TextField(
 controller: _nomePac,
 decoration: AdminStyles.campo('Nome do paciente'),
 ),
 const SizedBox(height: 10),
 TextField(
 controller: _dataConsulta,
 decoration: AdminStyles.campo('Data (DD/MM/AAAA)'),
 keyboardType: TextInputType.datetime,
 ),
 const SizedBox(height: 12),
 ElevatedButton(
 onPressed: _criarConsultaTeste,
 style: ElevatedButton.styleFrom(
 backgroundColor: AppColors.sucesso,
 foregroundColor: AppColors.branco,
 padding: const EdgeInsets.symmetric(vertical: 14),
 ),
 child: const Text('Criar Consulta'),
 ),
 ],
 ),
 const SizedBox(height: 40),
 ],
 ),
 ),
 );
 }
}

class _SecaoAdmin extends StatelessWidget {
 const _SecaoAdmin({required this.titulo, required this.children});

 final String titulo;
 final List<Widget> children;

 @override
 Widget build(BuildContext context) {
 return Container(
 width: double.infinity,
 padding: const EdgeInsets.all(20),
 decoration: AdminStyles.secao,
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.stretch,
 children: [
 Text(titulo, style: AdminStyles.tituloSecao),
 const SizedBox(height: 15),
 ...children,
 ],
 ),
 );
 }
}
