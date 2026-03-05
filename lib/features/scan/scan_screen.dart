import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/providers/ai_provider.dart';
import 'package:verd/providers/auth_provider.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _cameraController;
  bool _isInit = false;
  bool _isProcessing = false;

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
  Future<void> _takeScanPicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppToast.show(context, message: 'Please log in to use the scanner', variant: ToastVariant.error);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final xFile = await _cameraController!.takePicture();
      final imageFile = File(xFile.path);
      
      final scanId = const Uuid().v4();
      
      AppToast.show(context, message: 'Analyzing scan via Hybrid AI...', variant: ToastVariant.info);

      final result = await ref.read(aiRoutingServiceProvider).routeScan(
        userId: user.uid,
        scanId: scanId,
        image: imageFile,
      );

      if (mounted) {
        // TODO: Navigate to Scan Results Screen with the result data
        // For now, print status to show success
        AppToast.show(
          context, 
          message: 'Analysis Complete! Engine: ${result['engine']}', 
          variant: ToastVariant.success
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Error analyzing image: $e', variant: ToastVariant.error);
        debugPrint('Scan error: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
                            onPressed: _isProcessing ? null : _takeScanPicture,
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
