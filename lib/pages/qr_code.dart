// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCode extends StatefulWidget {
  final userData;
  const QrCode({Key? key, required this.userData}) : super(key: key);
  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final user = FirebaseAuth.instance.currentUser;
  var qrCode = '';
  var backgroundQrCode = Color.fromARGB(255, 233, 232, 232);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        qrCode = widget.userData['qr_code'];
        backgroundQrCode = Color.fromARGB(255, 0, 0, 0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 233, 232, 232),
                borderRadius: BorderRadius.circular(24),
              ),
              child: QrImage(
                data: qrCode,
                size: 200,
                foregroundColor: backgroundQrCode,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              'QrCode',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromARGB(255, 0, 21, 76),
                  fontFamily: 'Poppins'),
            ),
          ],
        )),
      ),
    );
  }
}
