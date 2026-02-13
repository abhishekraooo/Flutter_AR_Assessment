import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArScreen extends StatefulWidget {
  const ArScreen({Key? key}) : super(key: key);

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  ArCoreController? _arCoreController;

  bool _isPlaneDetected = false;
  bool _objectPlaced = false;
  bool _showInfo = false;

  int _viewKeyCounter = 0;

  void _onArCoreViewCreated(ArCoreController controller) {
    _arCoreController = controller;

    _arCoreController?.onPlaneDetected = (_) {
      if (!_isPlaneDetected && mounted) {
        setState(() {
          _isPlaneDetected = true;
        });
      }
    };

    _arCoreController?.onPlaneTap = _handlePlaneTap;
    _arCoreController?.onNodeTap = _handleNodeTap;
  }

  void _handlePlaneTap(List<ArCoreHitTestResult> hits) {
    if (_objectPlaced || hits.isEmpty) return;

    final hit = hits.first;

    try {
      final material = ArCoreMaterial(
        color: Colors.red,
        metallic: 0.0,
        reflectance: 0.5,
      );

      final cube = ArCoreCube(
        materials: [material],
        size: vector.Vector3(0.2, 0.2, 0.2),
      );

      final node = ArCoreNode(
        name: 'cube',
        shape: cube,
        position: vector.Vector3(
          hit.pose.translation.x,
          hit.pose.translation.y,
          hit.pose.translation.z,
        ),
      );

      _arCoreController?.addArCoreNodeWithAnchor(node);

      setState(() {
        _objectPlaced = true;
      });
    } catch (_) {
      _restartArView();
    }
  }

  void _handleNodeTap(String name) {
    if (name == 'cube') {
      setState(() {
        _showInfo = !_showInfo;
      });
    }
  }

  void _restartArView() {
    try {
      _arCoreController?.dispose();
    } catch (_) {}

    setState(() {
      _viewKeyCounter++;
      _isPlaneDetected = false;
      _objectPlaced = false;
      _showInfo = false;
    });
  }

  Widget _instructionCard() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _objectPlaced
              ? 'Object placed. Tap cube to learn more.'
              : _isPlaneDetected
              ? 'Tap on the surface to place the object.'
              : 'Move your phone slowly to find a surface.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => setState(() => _showInfo = false),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Magic Cube',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('• Placed using Augmented Reality'),
              Text('• Anchored in the real world'),
              Text('• Tap Reset to place again'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resetButton() {
    return Positioned(
      top: 40,
      right: 16,
      child: ElevatedButton.icon(
        onPressed: _restartArView,
        icon: const Icon(Icons.refresh),
        label: const Text(
          'Reset',
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArCoreView(
            key: ValueKey('arcore_$_viewKeyCounter'),
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
            enableUpdateListener: false,
          ),
          _instructionCard(),
          if (_showInfo) _infoCard(),
          _resetButton(),
        ],
      ),
    );
  }
}
