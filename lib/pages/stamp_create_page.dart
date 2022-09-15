// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StampCreatePage extends StatefulWidget {
  var userData;
  StampCreatePage({Key? key, required this.userData}) : super(key: key);
  @override
  State<StampCreatePage> createState() => _StampCreatePageState();
}

class _StampCreatePageState extends State<StampCreatePage> {
  final _stampNameController = TextEditingController();
  final _stampDescriptionController = TextEditingController();
  final _stampRewardController = TextEditingController();
  final _stampQuantityController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> stampsMap = Map.fromEntries(<String, dynamic>{
    'stamps': <String, dynamic>{'stamps': 'initiationValue'},
  }.entries);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var stampsMapTemp = widget.userData.data();
      if (stampsMapTemp.containsKey('stamps')) {
        stampsMap = widget.userData.data();
        stampsMap.removeWhere((key, value) => key != 'stamps');
      }
      setState(() {
        cardShower('');
      });
      ;
    });
  }

  Future<void> createStamp() async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);

    final stampConfiguration = {
      'stamp_description': _stampDescriptionController.text.toString(),
      'stamp_reward': _stampRewardController.text.toString(),
      'stamp_quantity': _stampQuantityController.text.toString(),
    };
    final stampName = 'stamps.${_stampNameController.text}';
    docUser.update({stampName: stampConfiguration});
    widget.userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid.toString())
        .get()
        .then((value) {
      return value;
    });

    stampsMap = widget.userData.data();
    stampsMap.removeWhere((key, value) => key != 'stamps');
    setState(() {
      cardShower('');
    });
  }

  Widget cardShower(var i) {
    if (i.runtimeType == String) {
      return Text('updating');
    }

    if (i.value.runtimeType == String) {
      return Text('Você ainda não tem carimbos criados :/');
    }

    if (i.value == '{stamps: initiationValue}') {
      return Text('Você ainda não tem carimbos criados :/');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(children: [
          Text(
            i.key.toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 0, 21, 76),
                fontFamily: 'Poppins'),
          ),
          SizedBox(
            height: 10,
            width: 300,
          ),
          Text('Descrição:' + i.value['stamp_description'].toString()),
          Text('Quantidade para resgatar a recompensa:' +
              i.value['stamp_quantity'].toString()),
          Text('Recompensa:' + i.value['stamp_reward'].toString()),
        ]),
      ),
    );
  }

  Future openCreateStampDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Criar carimbo'),
            content:
                // Create stamp field
                SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextFormField(
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(60),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                      controller: _stampNameController,
                      decoration: InputDecoration(
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
                          hintText: 'Nome do carimbo',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 167, 167, 167))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextFormField(
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(60),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                      controller: _stampDescriptionController,
                      decoration: InputDecoration(
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
                          hintText: 'Descrição do carimbo',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 167, 167, 167))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextFormField(
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(60),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                      controller: _stampRewardController,
                      decoration: InputDecoration(
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
                          hintText: 'Prêmio do carimbo',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 167, 167, 167))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextFormField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                      controller: _stampQuantityController,
                      decoration: InputDecoration(
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
                          hintText: 'Quantidade até o premio',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 167, 167, 167))),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (() {
                    createStamp();
                    Navigator.pop(context);
                  }),
                  child: Text('Criar')),
            ],
          ));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              if (widget.userData['type_of_account'] == 'commercial')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      openCreateStampDialog();
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
                              'Criar carimbo',
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
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
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
              SizedBox(height: 25),
              Text(
                'Seus carimbos:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color.fromARGB(255, 20, 28, 53),
                    fontFamily: 'Poppins'),
              ),
              SizedBox(height: 25),
              for (var v in stampsMap['stamps'].entries) cardShower(v),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
