import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;
        _cameraController = CameraController(
          firstCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInit = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for camera
      body: Stack(
        children: [
          // ── Camera Background ──
          if (_isInit && _cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // ── UI Overlay ──
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // ── Top Bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCircularIconButton(
                          icon: Icons.history,
                          onPressed: () {
                            context.push('/scan-history');
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Instruction Pill ──
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50), // Green
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Position crop within frame',
                      style: AppTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ── Viewfinder Area ──
                  const Spacer(),
                  Center(
                    child: Stack(
                      children: [
                        // Main Viewfinder Box
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: MediaQuery.sizeOf(context).width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            children: [
                              // Rule of Thirds Grid Lines (Horizontal)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                                  Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                                ],
                              ),
                              // Rule of Thirds Grid Lines (Vertical)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(width: 1, color: Colors.white.withValues(alpha: 0.2)),
                                  Container(width: 1, color: Colors.white.withValues(alpha: 0.2)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // ── Corner Brackets ──
                        ..._buildCornerBrackets(MediaQuery.sizeOf(context).width * 0.8, 24.0),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ── Bottom Action Buttons ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxxl * 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircularIconButton(
                          icon: Icons.upload_outlined,
                          onPressed: () {
                            AppToast.show(
                              context,
                              message: 'Upload coming soon',
                              variant: ToastVariant.info,
                            );
                          },
                          size: 64,
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 36),
                            onPressed: () {
                              AppToast.show(
                                context,
                                message: 'AI model loading...',
                                variant: ToastVariant.info,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        _buildCircularIconButton(
                          icon: Icons.insert_photo_outlined,
                          onPressed: () {
                            context.push('/gallery');
                          },
                          size: 64,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF333333), // Darker grey for buttons
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.45),
        onPressed: onPressed,
      ),
    );
  }

  List<Positioned> _buildCornerBrackets(double boxSize, double strokeWidth) {
    const double lineLength = 40.0;
    const double thickness = 4.0;
    const Color color = Colors.white;

    return [
      // Top Left
      Positioned(
        top: -1,
        left: -1,
        child: _buildCorner(lineLength, thickness, color, isTop: true, isLeft: true),
      ),
      // Top Right
      Positioned(
        top: -1,
        right: -1,
        child: _buildCorner(lineLength, thickness, color, isTop: true, isLeft: false),
      ),
      // Bottom Left
      Positioned(
        bottom: -1,
        left: -1,
        child: _buildCorner(lineLength, thickness, color, isTop: false, isLeft: true),
      ),
      // Bottom Right
      Positioned(
        bottom: -1,
        right: -1,
        child: _buildCorner(lineLength, thickness, color, isTop: false, isLeft: false),
      ),
    ];
  }

  Widget _buildCorner(double length, double thickness, Color color, {required bool isTop, required bool isLeft}) {
    // Instead of using complex paths, define an L shape with containers
    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          // Horizontal part
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: length,
              height: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isTop && isLeft ? thickness : 0),
                  topRight: Radius.circular(isTop && !isLeft ? thickness : 0),
                  bottomLeft: Radius.circular(!isTop && isLeft ? thickness : 0),
                  bottomRight: Radius.circular(!isTop && !isLeft ? thickness : 0),
                ),
              ),
            ),
          ),
          // Vertical part
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              height: length,
              width: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isTop && isLeft ? thickness : 0),
                  topRight: Radius.circular(isTop && !isLeft ? thickness : 0),
                  bottomLeft: Radius.circular(!isTop && isLeft ? thickness : 0),
                  bottomRight: Radius.circular(!isTop && !isLeft ? thickness : 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
