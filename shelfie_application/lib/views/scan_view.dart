import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class ScanView extends StatelessWidget{
  const ScanView({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Boek Barcode')),
      body: MobileScanner(
        onDetect: (capture) async{
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes){
            if(barcode.rawValue != null){

              //Stop scanner om dubbele scans te voorkomen
              final isbn = barcode.rawValue!;
              debugPrint('Barcode gevonden: $isbn');

              Navigator.pop(context, isbn);
              break;
            }
          }
        },
      ),
    );
  }
}