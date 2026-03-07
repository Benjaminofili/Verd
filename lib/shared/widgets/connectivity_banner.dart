import 'package:verd/l10n/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONNECTIVITY BANNER
// Auto-shows when offline, auto-hides when back online.
// Wrap your Scaffold body with ConnectivityBanner.
// ═══════════════════════════════════════════════════════════════════════════

/// Wrap the Scaffold body with this widget.
/// It listens to [ConnectivityNotifier] and shows/hides automatically.
///
/// Usage:
///   body: ConnectivityBanner(
///     child: YourScreenContent(),
///   )
///
/// To trigger manually (e.g. from a Riverpod provider watching connectivity):
///   ConnectivityNotifier.of(context).setOffline(true);
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final bool? forceOffline; // override for testing in preview

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.forceOffline,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;

  // In production, swap this with a stream from connectivity_plus package:
  // StreamSubscription<ConnectivityResult>? _sub;
  bool _isOffline = false;
  bool _justReconnected = false;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightFactor =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    if (widget.forceOffline != null) {
      _setStatus(widget.forceOffline!);
    }

    // ── Production wiring (uncomment when connectivity_plus is added) ──
    // _sub = Connectivity().onConnectivityChanged.listen((result) {
    //   _setStatus(result == ConnectivityResult.none);
    // });
  }

  void _setStatus(bool offline) {
    if (!mounted) return;
    if (!offline && _isOffline) {
      // Just came back online — show "Back online" briefly
      setState(() {
        _isOffline = false;
        _justReconnected = true;
      });
      _ctrl.forward();
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _ctrl.reverse().then((_) {
            if (mounted) setState(() => _justReconnected = false);
          });
        }
      });
    } else if (offline && !_isOffline) {
      setState(() {
        _isOffline = true;
        _justReconnected = false;
      });
      _reconnectTimer?.cancel();
      _ctrl.forward();
    }
  }

  @override
  void didUpdateWidget(ConnectivityBanner old) {
    super.didUpdateWidget(old);
    if (widget.forceOffline != null &&
        widget.forceOffline != old.forceOffline) {
      _setStatus(widget.forceOffline!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _reconnectTimer?.cancel();
    // _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner slides down from top
        AnimatedBuilder(
          animation: _heightFactor,
          builder: (_, child) => ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
          child: _justReconnected
              ? _BannerContent(
                  message: AppLocalizations.of(context)!.back_online,
                  icon: Icons.wifi,
                  backgroundColor: AppColors.success,
                )
              : _BannerContent(
                  message: AppLocalizations.of(context)!.no_internet,
                  icon: Icons.wifi_off_outlined,
                  backgroundColor: AppColors.gray900,
                  trailing: TextButton(
                    onPressed: () {
                      // Trigger manual retry logic here
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(AppLocalizations.of(context)!.retry,
                        style: AppTypography.buttonSmall
                            .copyWith(color: Colors.white70)),
                  ),
                ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Widget? trailing;

  const _BannerContent({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
