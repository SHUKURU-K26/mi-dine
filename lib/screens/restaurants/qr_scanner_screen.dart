import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/glass_container.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _controller =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  final _manual = TextEditingController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    _manual.dispose();
    super.dispose();
  }

  void _finish(String code) {
    if (_handled || code.trim().isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final code = capture.barcodes
                  .map((b) => b.rawValue)
                  .whereType<String>()
                  .firstOrNull;
              if (code != null) _finish(code);
            },
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Point the camera at the Mi-Dine code on the menu',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 8,
            child: SafeArea(
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(CupertinoIcons.xmark,
                    color: Colors.white, size: 26),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manual,
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: _finish,
                          decoration: const InputDecoration(
                            hintText: 'Or type the code, e.g. MIDINE-BELLA',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _finish(_manual.text),
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(80, 52)),
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}