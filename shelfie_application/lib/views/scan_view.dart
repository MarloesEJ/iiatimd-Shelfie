import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import '../services/api_service.dart';

class ScanView extends StatelessWidget{
  final Function(String) onCodeDetected;

  const ScanView({super.key, required this.onCodeDetected});

  @override
  Widget build(BuildContext context){
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              onDetect: (capture){
                final List<Barcode> barcodes = capture.barcodes;
                for(final barcode in barcodes){
                  if(barcode.rawValue != null){
                    onCodeDetected(barcode.rawValue!);
                    break; //stop na eerste gedetecteerde code, voorkomt meerdere detecties.
                  }
                }
              },
            ),
          ),

          //terug knop naar de homepagina
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          //Elevated Tekstinvoer onderaan zwevend over de camera
          Positioned(
            bottom:  MediaQuery.of(context).padding.bottom + 20,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Voer ISBN of titel in.',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) {
                    if(value.trim().isNotEmpty){
                      onCodeDetected(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}