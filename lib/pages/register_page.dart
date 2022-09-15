// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 3 == 0 &&
          nonZeroIndex != text.length &&
          nonZeroIndex < 9) {
        buffer.write(
            '.'); // Replace this with anything you want to put after each 4 numbers
      } else if (nonZeroIndex == 9 && nonZeroIndex != text.length) {
        buffer.write('-');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final _emailController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  //final _chars =
  //    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  bool isCompany = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cpfCnpjController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future signUp() async {
    String cpfCnpj = _cpfCnpjController.text.replaceAll(RegExp('[^0-9]'), '');
    final isValid = _formKey.currentState?.validate();
    //var qrCode = getRandomString(10);
    if (isValid == null || !isValid) return;

    var isCpfCpfjNew = await FirebaseFirestore.instance
        .collection('users')
        .where('cpf_cnpj', isEqualTo: cpfCnpj)
        .get()
        .then((value) {
      if (!value.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });

    var isEmailNew = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .get()
        .then((value) {
      if (!value.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });

    if (isCpfCpfjNew == false) {
      print("cpf not new, going back.");
      final snackBarErrorCpf =
          snackBarErrorCreator('ERRO: Esse CPF/CPNJ já foi usado.');
      ScaffoldMessenger.of(context).showSnackBar(snackBarErrorCpf);
      return;
    }

    if (isEmailNew == false) {
      print("email not new, going back.");
      final snackBarErrorEmail =
          snackBarErrorCreator('ERRO: Esse e-mail já foi usado.');
      ScaffoldMessenger.of(context).showSnackBar(snackBarErrorEmail);
      return;
    }

    var userData = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());

    String typeOfAccount = isCompany ? 'commercial' : 'user';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userData.user?.uid)
        .set({
      'name': _nameController.text,
      'cpf_cnpj': cpfCnpj,
      'email': _emailController.text,
      'qr_code': userData.user?.uid,
      'type_of_account': typeOfAccount,
    });
  }

  SnackBar snackBarErrorCreator(String text) {
    return SnackBar(
        content: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))));
  }

  bool isCpfValid(value) {
    value = value!.replaceAll(RegExp('[^0-9]'), '');
    if (value.length < 11) {
      return false;
    }
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += (int.parse(value[i])) * (10 - i);
    }
    sum = (sum * 10) % 11;

    if (sum == 10 || sum == 11) {
      sum = 0;
    }

    if (value[9] != sum.toString()) {
      return false;
    } else {
      return true;
    }
  }

  bool isEmailValid(value) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
  }

  bool isPasswordValid(value) {
    return RegExp(r'.{6,}$').hasMatch(value);
  }

  //String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
  //  length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Texto de faça seu cadastro
                    const Text(
                      'Faça seu cadastro',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Color.fromARGB(255, 0, 21, 76),
                          fontFamily: 'Poppins'),
                    ),

                    const SizedBox(height: 10),

                    // Linha azul
                    const Divider(
                      thickness: 5,
                      color: Color.fromARGB(255, 41, 63, 117),
                      indent: 163,
                      endIndent: 163,
                    ),

                    const SizedBox(height: 40),

                    // Entrada de texto 'Nome'
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(60),
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                        controller: _nameController,
                        decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 136, 136, 136),
                                size: 20,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 15, top: 15, bottom: 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Nome',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167))),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // Entrada de texto 'CPF/CNPJ'
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          CustomInputFormatter()
                        ],
                        validator: (value) =>
                            isCpfValid(value) ? null : 'CPF Inválido.',
                        controller: _cpfCnpjController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: Icon(
                                Icons.numbers,
                                color: Color.fromARGB(255, 136, 136, 136),
                                size: 20,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 15, top: 15, bottom: 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 233, 8, 8),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'CPF/CNPJ',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167))),
                      ),
                    ),
                    const SizedBox(height: 13),

                    // Entrada de texto 'Email'
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(60),
                        ],
                        validator: (value) =>
                            isEmailValid(value) ? null : 'E-mail inválido.',
                        controller: _emailController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: Icon(
                                Icons.email_outlined,
                                color: Color.fromARGB(255, 136, 136, 136),
                                size: 20,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 15, top: 15, bottom: 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 233, 8, 8),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'E-mail',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167))),
                      ),
                    ),

                    SizedBox(height: 13),

                    // Entrada de texto 'Senha'
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextFormField(
                        obscureText: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(30),
                        ],
                        validator: (value) =>
                            isPasswordValid(value) ? null : 'Senha Inválida.',
                        controller: _passwordController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: Icon(
                                Icons.lock_person,
                                color: Color.fromARGB(255, 136, 136, 136),
                                size: 20,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 15, top: 15, bottom: 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 233, 8, 8),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 21, 76),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Senha',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167))),
                      ),
                    ),
                    const Text(
                      'Minímo de 6 caracteres.',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color.fromARGB(255, 95, 95, 95),
                          fontFamily: 'Poppins'),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: CheckboxListTile(
                        title: Text(
                          "Criar conta empresa",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        value: isCompany,
                        checkboxShape: CircleBorder(),
                        onChanged: (bool? value) {
                          setState(() => isCompany = value!);
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      // Botão Cadastrar
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: GestureDetector(
                            onTap: signUp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 45, vertical: 9.5),
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 21, 76),
                                  borderRadius: BorderRadius.circular(24)),
                              child: const Center(
                                child: Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Botão voltar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: GestureDetector(
                            onTap: widget.showLoginPage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 9.5),
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 21, 76),
                                  borderRadius: BorderRadius.circular(24)),
                              child: Text(
                                'Voltar',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
