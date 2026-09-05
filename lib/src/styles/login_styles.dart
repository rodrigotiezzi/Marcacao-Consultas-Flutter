import 'package:flutter/material.dart';

import 'app_colors.dart';

class LoginStyles {
  static const TextStyle marca = TextStyle(
    color: AppColors.branco,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const TextStyle titulo = TextStyle(
    color: AppColors.branco,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitulo = TextStyle(
    color: AppColors.branco,
    fontSize: 16,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.textoEscuro,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle botaoTexto = TextStyle(
    color: AppColors.branco,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle erroTexto = TextStyle(
    color: AppColors.perigo,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle infoTexto = TextStyle(
    color: AppColors.textoSecundario,
    fontSize: 13,
  );

  static BoxDecoration get cartao => BoxDecoration(
    color: AppColors.branco,
    borderRadius: BorderRadius.circular(16),
  );

  static BoxDecoration get erroCaixa => BoxDecoration(
    color: AppColors.fundoMensagemErro,
    borderRadius: BorderRadius.circular(8),
    border: const Border(left: BorderSide(color: AppColors.perigo, width: 4)),
  );
}


