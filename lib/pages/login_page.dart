import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                // Texto de boas vindas
                const Text(
                  'Seja bem-vindo(a)',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 41, 63, 117),
                      fontFamily: 'Poppins'),
                ),

                const SizedBox(height: 5),

                // Texto de faça seu login
                const Text(
                  'Faça seu login',
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

                // Entrada de texto 'Email'
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 221, 221, 221),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(60),
                        ],
                        controller: _emailController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                        decoration: const InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 0, 21, 76),
                                size: 30,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15.0),
                            border: InputBorder.none,
                            hintText: 'Email',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167))),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                // Entrada de texto 'Senha'
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 221, 221, 221),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        obscureText: true,
                        controller: _passwordController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15.0),
                            border: InputBorder.none,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: Icon(
                                Icons.lock_person,
                                color: Color.fromARGB(255, 0, 21, 76),
                                size: 30,
                              ),
                            ),
                            hintText: 'Senha',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167))),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  // Botão login
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                        onTap: signIn,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 45, vertical: 9.5),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 21, 76),
                              borderRadius: BorderRadius.circular(24)),
                          child: const Center(
                            child: Text(
                              'Login',
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

                    // Botão cadastrar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 9.5),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 21, 76),
                              borderRadius: BorderRadius.circular(24)),
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
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
