import 'package:flutter/material.dart';

import '../data/storage.dart';
import '../models/models.dart';
import '../routes/app_routes.dart';
import '../styles/styles.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  final _dataConsulta = TextEditingController();

  List<Especialidade> _especialidades = [];
  List<Medico> _medicos = [];
  List<Medico> _medicosFiltrados = [];
  Especialidade? _especialidadeSelecionada;
  Medico? _medicoSelecionado;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _dataConsulta.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final especialidades = await Storage.obterEspecialidades();
    final medicos = await Storage.obterMedicos();
    if (!mounted) {
      return;
    }
    setState(() {
      _especialidades = especialidades;
      _medicos = medicos;
      _carregando = false;
    });
  }

  void _selecionarEspecialidade(Especialidade? especialidade) {
    setState(() {
      _especialidadeSelecionada = especialidade;
      _medicoSelecionado = null;
      _medicosFiltrados = especialidade == null
          ? []
          : _medicos
                .where((medico) => medico.especialidade.id == especialidade.id)
                .toList();
    });
  }

  DateTime? _parseData(String texto) {
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(texto)) {
      return null;
    }
    final partes = texto.split('/');
    return DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
  }

  void _mostrarAlerta(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: AppColors.perigo),
    );
  }

  Future<void> _agendarConsulta() async {
    if (_especialidadeSelecionada == null) {
      _mostrarAlerta('Selecione uma especialidade');
      return;
    }
    if (_medicoSelecionado == null) {
      _mostrarAlerta('Selecione um médico');
      return;
    }
    if (_dataConsulta.text.trim().isEmpty) {
      _mostrarAlerta('Informe a data da consulta');
      return;
    }

    final data = _parseData(_dataConsulta.text.trim());
    if (data == null) {
      _mostrarAlerta('Use o formato DD/MM/AAAA para a data');
      return;
    }

    final hoje = DateTime.now();
    final hojeZerado = DateTime(hoje.year, hoje.month, hoje.day);
    if (data.isBefore(hojeZerado)) {
      _mostrarAlerta('Não é possível agendar consultas no passado');
      return;
    }

    final paciente = await Storage.obterPacienteLogado();
    if (!mounted) {
      return;
    }
    if (paciente == null) {
      _mostrarAlerta('Você precisa estar logado para agendar');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final novaConsulta = Consulta(
      id: DateTime.now().millisecondsSinceEpoch,
      medico: _medicoSelecionado!,
      paciente: paciente,
      data: data,
      valor: 350,
      status: StatusConsulta.agendada,
      observacoes: 'Consulta agendada via app',
    );

    final consultas = await Storage.obterConsultas();
    await Storage.salvarConsultas([...consultas, novaConsulta]);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Sucesso!'),
          content: Text(
            'Consulta agendada com ${_medicoSelecionado!.nome} para ${_dataConsulta.text}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo),
              child: const Text('Ver minhas consultas'),
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
        title: const Text('Agendar Consulta'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AdminStyles.paddingTela,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AdminStyles.secao,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '1. Especialidade',
                        style: AdminStyles.tituloSecao,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Especialidade>(
                        key: ValueKey(_especialidadeSelecionada?.id),
                        initialValue: _especialidadeSelecionada,
                        decoration: AdminStyles.campo(
                          'Selecione a especialidade',
                        ),
                        items: _especialidades
                            .map(
                              (especialidade) => DropdownMenuItem(
                                value: especialidade,
                                child: Text(especialidade.nome),
                              ),
                            )
                            .toList(),
                        onChanged: _selecionarEspecialidade,
                      ),
                      const SizedBox(height: 20),
                      const Text('2. Médico', style: AdminStyles.tituloSecao),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Medico>(
                        key: ValueKey(
                          '${_especialidadeSelecionada?.id}-${_medicoSelecionado?.id}',
                        ),
                        initialValue: _medicoSelecionado,
                        decoration: AdminStyles.campo(
                          _especialidadeSelecionada == null
                              ? 'Escolha a especialidade primeiro'
                              : 'Selecione o médico',
                        ),
                        items: _medicosFiltrados
                            .map(
                              (medico) => DropdownMenuItem(
                                value: medico,
                                child: Text(medico.nome),
                              ),
                            )
                            .toList(),
                        onChanged: _especialidadeSelecionada == null
                            ? null
                            : (medico) =>
                                  setState(() => _medicoSelecionado = medico),
                      ),
                      const SizedBox(height: 20),
                      const Text('3. Data', style: AdminStyles.tituloSecao),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _dataConsulta,
                        keyboardType: TextInputType.datetime,
                        decoration: AdminStyles.campo('DD/MM/AAAA'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _agendarConsulta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sucesso,
                          foregroundColor: AppColors.branco,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Agendar consulta'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}


