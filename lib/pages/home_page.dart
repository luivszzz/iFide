// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ifide/pages/qr_code.dart';
import 'package:ifide/pages/qr_code_reader.dart';
import 'package:ifide/pages/stamp_create_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  var userData;
  Map<String, dynamic> stampsMap = Map();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllUserData();
    });
  }

  Future getAllUserData() async {
    userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid.toString())
        .get()
        .then((value) {
      print(value);
      return value;
    });
  }

  void getStamps() {
    stampsMap = userData.data();
    if (stampsMap.containsKey('stamps')) {
      stampsMap.removeWhere((key, value) => key != 'stamps');
    }
  }

  Widget cardShower(var i) {
    return TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QrCodeReader(
                      userData: userData, stampName: i.key.toString())));
        },
        child: Text(i.key.toString()));
  }

  Future openSelectStampDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Selecione um carimbo'),
            content: SingleChildScrollView(
              child: Column(children: [
                for (var v in stampsMap['stamps'].entries) cardShower(v),
              ]),
            ),
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Botao seus carimbos

          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StampCreatePage(userData: userData)))
                    .then((_) => getAllUserData());
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(300, 125),
                  primary: Color.fromARGB(255, 207, 207, 207),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment(-0.5, 0),
                      child: Text(
                        'Seus \nCarimbos',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color.fromARGB(255, 41, 63, 117),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 160, 160, 160),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Icon(
                        color: Color.fromARGB(255, 207, 207, 207),
                        Icons.control_camera,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 50),

          //Botao veja seu perfil

          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(300, 125),
                  primary: Color.fromARGB(255, 207, 207, 207),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment(-0.5, 0),
                      child: Text(
                        'Veja \nseu Perfil',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color.fromARGB(255, 41, 63, 117),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 160, 160, 160),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Icon(
                        color: Color.fromARGB(255, 207, 207, 207),
                        Icons.person,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 50),

          // Botão qrcode

          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                if (userData['type_of_account'] == 'commercial') {
                  stampsMap = userData.data();
                  if (stampsMap.containsKey('stamps')) {
                    getStamps();
                    openSelectStampDialog();
                  }
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QrCode(userData: userData)));
                }
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(75, 75),
                  primary: Color.fromARGB(255, 27, 14, 141),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(46))),
              child: Icon(
                color: Color.fromARGB(255, 255, 255, 255),
                Icons.qr_code_sharp,
                size: 40,
              ),
            ),
          ),
        ],
      )),
    ));
  }
}
