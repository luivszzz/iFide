// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeReader extends StatefulWidget {
  var userData;

  String stampName;
  QrCodeReader(
      {Key? key, required this.userData, required String this.stampName})
      : super(key: key);
  @override
  State<QrCodeReader> createState() => _QrCodeReaderState();
}

class _QrCodeReaderState extends State<QrCodeReader> {
  final user = FirebaseAuth.instance.currentUser;
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;
  QRViewController? controller;
  var testText = 'Procurando QRCode...';

  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Future<void> addUserToStamp(var barcode) async {
    Map<String, dynamic> stampsMap = widget.userData.data();
    var docUserInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(barcode)
        .get()
        .then((value) {
      return value;
    });

    Map<String, dynamic>? stampsMapClient = docUserInfo.data();

    final docUser = FirebaseFirestore.instance.collection('users').doc(barcode);

    if (stampsMapClient!.containsKey('stamps')) {
      if (stampsMapClient['stamps'].containsKey(widget.stampName)) {
        String stampQuantityString =
            stampsMapClient['stamps'][widget.stampName]['stamp_quantity'];

        String stampQuantityStringStart =
            stampQuantityString.substring(0, stampQuantityString.indexOf('/'));
        String stampQuantityStringEnd =
            stampQuantityString.substring(stampQuantityString.indexOf('/') + 1);

        int stampQuantity = int.parse(stampQuantityStringStart) + 1;
        stampQuantityString =
            stampQuantity.toString() + '/' + stampQuantityStringEnd;

        docUser.update({
          'stamps.' + widget.stampName + '.' + 'stamp_quantity':
              stampQuantityString
        });
      } else {
        final stampConfiguration = {
          'stamp_description': stampsMap['stamps'][widget.stampName]
              ['stamp_description'],
          'stamp_reward': stampsMap['stamps'][widget.stampName]['stamp_reward'],
          'stamp_quantity':
              '1/' + stampsMap['stamps'][widget.stampName]['stamp_quantity'],
        };
        final stampName = 'stamps.${widget.stampName}';
        docUser.update({stampName: stampConfiguration});
      }
    } else {
      final stampConfiguration = {
        'stamp_description': stampsMap['stamps'][widget.stampName]
            ['stamp_description'],
        'stamp_reward': stampsMap['stamps'][widget.stampName]['stamp_reward'],
        'stamp_quantity':
            '1/' + stampsMap['stamps'][widget.stampName]['stamp_quantity'],
      };
      final stampName = 'stamps.${widget.stampName}';
      docUser.update({stampName: stampConfiguration});
    }

    controller!.pauseCamera();
    setState(() {
      testText = 'Adicionado';
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller?.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            )),
        Text(testText)
      ],
    ));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream
        .listen((barcode) => addUserToStamp(barcode.code));
  }
}
