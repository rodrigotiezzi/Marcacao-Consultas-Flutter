import 'package:flutter/material.dart';

import '../data/storage.dart';
import '../models/models.dart';
import '../routes/app_routes.dart';
import '../styles/styles.dart';

enum EtapaLogin { cpf, cadastro }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with RouteAware {
  final _cpf = TextEditingController();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();

  EtapaLogin _etapa = EtapaLogin.cpf;
  bool _verificando = false;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _verificarSessao();
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
    _cpf.dispose();
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final logado = await Storage.obterPacienteLogado();
    if (!mounted) {
      return;
    }
    if (logado != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    setState(() {
      _etapa = EtapaLogin.cpf;
      _cpf.clear();
      _nome.clear();
      _email.clear();
      _telefone.clear();
      _erro = '';
      _verificando = false;
    });
  }

  Future<void> _verificarCpf() async {
    setState(() => _erro = '');

    if (_cpf.text.trim().isEmpty) {
      _mostrarAlerta('Por favor, preencha seu CPF');
      return;
    }
    if (!cpfValido(_cpf.text)) {
      _mostrarAlerta('CPF deve ter 11 dígitos');
      return;
    }

    setState(() => _verificando = true);
    try {
      final pacientes = await Storage.obterPacientes();
      final digitado = cpfSomenteDigitos(_cpf.text);
      final encontrados = pacientes.where(
        (paciente) => cpfSomenteDigitos(paciente.cpf) == digitado,
      );
      final existente = encontrados.isEmpty ? null : encontrados.first;

      if (!mounted) {
        return;
      }

      if (existente != null) {
        await Storage.salvarPacienteLogado(existente);
        if (!mounted) {
          return;
        }
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return;
      }

      setState(() {
        _erro =
            'CPF não encontrado no cadastro. Verifique se digitou corretamente.';
      });
    } catch (erro) {
      debugPrint('Erro ao verificar CPF: $erro');
      _mostrarAlerta('Não foi possível verificar o CPF');
    } finally {
      if (mounted) {
        setState(() => _verificando = false);
      }
    }
  }

  Future<void> _completarCadastro() async {
    if (_nome.text.trim().isEmpty) {
      _mostrarAlerta('Por favor, preencha seu nome');
      return;
    }
    if (_email.text.trim().isEmpty) {
      _mostrarAlerta('Por favor, preencha seu email');
      return;
    }

    setState(() => _verificando = true);
    try {
      final novoPaciente = Paciente(
        id: DateTime.now().millisecondsSinceEpoch,
        nome: _nome.text.trim(),
        cpf: _cpf.text.trim(),
        email: _email.text.trim(),
        telefone: _telefone.text.trim().isEmpty ? null : _telefone.text.trim(),
      );

      final pacientes = await Storage.obterPacientes();
      await Storage.salvarPacientes([...pacientes, novoPaciente]);
      await Storage.salvarPacienteLogado(novoPaciente);

      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (erro) {
      debugPrint('Erro ao cadastrar: $erro');
      _mostrarAlerta('Não foi possível realizar o cadastro');
    } finally {
      if (mounted) {
        setState(() => _verificando = false);
      }
    }
  }

  void _mostrarAlerta(String mensagem) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: AppColors.perigo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaria,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('TDSPO', style: LoginStyles.marca),
              const SizedBox(height: 12),
              const Text('Bem-vindo!', style: LoginStyles.titulo),
              const SizedBox(height: 8),
              Text(
                _etapa == EtapaLogin.cpf
                    ? 'Informe seu CPF para continuar'
                    : 'Complete seu cadastro',
                style: LoginStyles.subtitulo,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: LoginStyles.cartao,
                child: _etapa == EtapaLogin.cpf
                    ? _EtapaCpf(
                        controller: _cpf,
                        verificando: _verificando,
                        erro: _erro,
                        onCpfAlterado: () => setState(() => _erro = ''),
                        onContinuar: _verificarCpf,
                        onFazerCadastro: () =>
                            setState(() => _etapa = EtapaLogin.cadastro),
                      )
                    : _EtapaCadastro(
                        cpf: _cpf.text,
                        nome: _nome,
                        email: _email,
                        telefone: _telefone,
                        verificando: _verificando,
                        onFinalizar: _completarCadastro,
                        onVoltar: () => setState(() => _etapa = EtapaLogin.cpf),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtapaCpf extends StatelessWidget {
  const _EtapaCpf({
    required this.controller,
    required this.verificando,
    required this.erro,
    required this.onCpfAlterado,
    required this.onContinuar,
    required this.onFazerCadastro,
  });

  final TextEditingController controller;
  final bool verificando;
  final String erro;
  final VoidCallback onCpfAlterado;
  final VoidCallback onContinuar;
  final VoidCallback onFazerCadastro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('CPF *', style: LoginStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: !verificando,
          keyboardType: TextInputType.number,
          maxLength: 14,
          decoration: AdminStyles.campo('000.000.000-00'),
          onChanged: (_) => onCpfAlterado(),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: verificando ? null : onContinuar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaria,
            foregroundColor: AppColors.branco,
            disabledBackgroundColor: AppColors.textoSecundario,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            verificando ? 'Verificando...' : 'Continuar',
            style: LoginStyles.botaoTexto,
          ),
        ),
        if (erro.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: LoginStyles.erroCaixa,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(erro, style: LoginStyles.erroTexto),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onFazerCadastro,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaria,
                    side: const BorderSide(color: AppColors.primaria),
                  ),
                  child: const Text('Fazer cadastro agora'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Se você já é cadastrado, faremos login automaticamente.',
          style: LoginStyles.infoTexto,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EtapaCadastro extends StatelessWidget {
  const _EtapaCadastro({
    required this.cpf,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.verificando,
    required this.onFinalizar,
    required this.onVoltar,
  });

  final String cpf;
  final TextEditingController nome;
  final TextEditingController email;
  final TextEditingController telefone;
  final bool verificando;
  final VoidCallback onFinalizar;
  final VoidCallback onVoltar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('CPF', style: LoginStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: cpf,
          enabled: false,
          decoration: AdminStyles.campo('CPF'),
        ),
        const SizedBox(height: 12),
        const Text('Nome Completo *', style: LoginStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: nome,
          enabled: !verificando,
          textCapitalization: TextCapitalization.words,
          decoration: AdminStyles.campo('Digite seu nome completo'),
        ),
        const SizedBox(height: 12),
        const Text('Email *', style: LoginStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: email,
          enabled: !verificando,
          keyboardType: TextInputType.emailAddress,
          decoration: AdminStyles.campo('seu@email.com'),
        ),
        const SizedBox(height: 12),
        const Text('Telefone', style: LoginStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: telefone,
          enabled: !verificando,
          keyboardType: TextInputType.phone,
          decoration: AdminStyles.campo('(11) 98765-4321'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: verificando ? null : onFinalizar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sucesso,
            foregroundColor: AppColors.branco,
            disabledBackgroundColor: AppColors.textoSecundario,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            verificando ? 'Cadastrando...' : 'Finalizar Cadastro',
            style: LoginStyles.botaoTexto,
          ),
        ),
        TextButton(
          onPressed: verificando ? null : onVoltar,
          child: const Text('← Voltar'),
        ),
      ],
    );
  }
}


