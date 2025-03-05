import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';


class ScanCode extends StatefulWidget {
  const ScanCode({super.key,});

  @override
  State<ScanCode> createState() => _ScanState();
}
class _ScanState extends State<ScanCode> {
  String _scanResult = 'No se ha escaneado';

  Future<void> startBarcodeScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    if (result is String) {
      setState(() {
        _scanResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Scan result: $_scanResult\n'),
            ElevatedButton(
              onPressed: startBarcodeScan,
              child: const Text('Start Barcode Scan'),
            ),
          ],
        ),
      ),
    );
  }
}