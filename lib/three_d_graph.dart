import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'main.dart';
import '../theme/theme_constants.dart';



class ThreeDGraph extends StatefulWidget {
  final String equation;

  const ThreeDGraph({super.key, required this.equation});

  @override
  State<ThreeDGraph> createState() => _ThreeDGraphState();
}

class _ThreeDGraphState extends State<ThreeDGraph> {
  late Object surfaceObject;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _buildPlaceholderSurface(); // Replace this with backend point conversion later
  }

  void _buildPlaceholderSurface() {
    surfaceObject = Object(
      fileName: 'assets/cube/cube.obj', // You can include a custom .obj here
      scale: Vector3(3.0, 3.0, 3.0),
    );

    setState(() => isLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: ThemeConstants.graphBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.4), width: 1),
      ),
      child: isLoaded
          ? Cube(
              onSceneCreated: (Scene scene) {
                scene.camera.zoom = 10;
                scene.world.add(surfaceObject);
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
