import 'package:flutter/material.dart';

import 'app_colors.dart';

class AdminStyles {
 static const EdgeInsets paddingTela = EdgeInsets.all(20);

 static const TextStyle tituloSecao = TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 color: AppColors.textoEscuro,
 );

 static const TextStyle itemLista = TextStyle(
 fontSize: 14,
 color: AppColors.textoSecundario,
 );

 static BoxDecoration get secao => BoxDecoration(
 color: AppColors.branco,
 borderRadius: BorderRadius.circular(8),
 );

 static InputDecoration campo(String rotulo) {
 return InputDecoration(
 hintText: rotulo,
 filled: true,
 fillColor: AppColors.fundoInput,
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8),
 borderSide: const BorderSide(color: AppColors.bordaInput),
 ),
 enabledBorder: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8),
 borderSide: const BorderSide(color: AppColors.bordaInput),
 ),
 contentPadding: const EdgeInsets.all(12),
 );
 }
}
