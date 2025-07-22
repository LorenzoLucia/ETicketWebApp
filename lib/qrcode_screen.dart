import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatefulWidget {
  final String? ticketId;
  final ApiService apiService;

  const QRScreen({super.key, this.ticketId, required this.apiService});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final gitUrl =
      "https://raw.githubusercontent.com/LorenzoLucia/ETicketTotem/refs/heads/main/ticket_files";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void _endTicketPurchase() {
  //   Navigator.of(context).popUntil((route) => route.isFirst);
  // }

  QrCode _createQrCode() {
    return QrCode(6, QrErrorCorrectLevel.L)
      ..addData("$gitUrl/${widget.ticketId}.svg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR code')),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [QrImageView.withQr(qr: _createQrCode(), size: 250)],
          ),
        ),
      ),
    );
  }
}
