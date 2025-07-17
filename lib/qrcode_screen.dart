import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  final String? ticketId;
  final ApiService apiService;

  QRScreen({super.key, this.ticketId, required this.apiService});

  final gitUrl =
      "https://raw.githubusercontent.com/LorenzoLucia/ETicketTotem/refs/heads/main/ticket_files";

  QrCode _createQrCode() {
    return QrCode(6, QrErrorCorrectLevel.L)..addData("$gitUrl/$ticketId.svg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save your E-Ticket!'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            QrImageView.withQr(qr: _createQrCode(), size: 280),
            Text("$gitUrl/$ticketId.svg"),
          ],
        ),
      ),
    );
  }
}
