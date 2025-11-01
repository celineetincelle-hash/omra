import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../features/bluetooth/group_bluetooth_service.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isScanning = true;
  final GroupBluetoothService _groupService = GroupBluetoothService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('scan_qr')),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
              if (_isScanning) {
                controller.start();
              } else {
                controller.stop();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                // Le widget de scan
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
                // Overlay personnalisé pour simuler QrScannerOverlayShape
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(tr('scan_code')),
            ),
          )
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    // Vérifie si le scan est actif
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      
      // Arrêter le scan pour éviter plusieurs lectures
      setState(() {
        _isScanning = false;
      });
      controller.stop();
      
      // Traiter le code QR
      _processQRCode(code);
    }
  }

  void _processQRCode(String? code) {
    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('invalid_code'))),
      );
      _resumeScanning();
      return;
    }
    
    // Vérifier si le code correspond au format attendu
    if (code.startsWith('OMRA-') && code.length == 12) {
      // Rejoindre le groupe
      _joinGroup(code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('invalid_code'))),
      );
      _resumeScanning();
    }
  }
  
  Future<void> _joinGroup(String groupId) async {
    try {
      await _groupService.joinGroup(groupId);
      
      // Naviguer vers l'écran de gestion de groupe
      if (mounted) {
        context.go('/group');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('group_joined'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
        _resumeScanning();
      }
    }
  }
  
  void _resumeScanning() {
    setState(() {
      _isScanning = true;
    });
    controller.start();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
