import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/mock/mock_data.dart';
import '../data/models/misc_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_links.dart';

/// A swipeable launch notice popup. Shows once per app launch (and again when
/// the bell is tapped). Replaces the old in-app notifications screen.
class NoticePopup {
  NoticePopup._();

  static bool _shownThisLaunch = false;

  /// Shows the popup only the first time per app launch.
  static void showIfFirstLaunch() {
    if (_shownThisLaunch) return;
    _shownThisLaunch = true;
    show();
  }

  /// Always shows the popup (used by the bell icon).
  static void show() {
    if (MockData.notices.isEmpty) return;
    Get.dialog(
      const _NoticeDialog(notices: MockData.notices),
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }
}

class _NoticeDialog extends StatefulWidget {
  final List<NoticeItem> notices;
  const _NoticeDialog({required this.notices});

  @override
  State<_NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogState extends State<_NoticeDialog> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int to) {
    final i = to.clamp(0, widget.notices.length - 1);
    _controller.animateToPage(i,
        duration: AppDurations.base, curve: AppCurves.emphasized);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Square card: side = available width (capped), so the image is square.
    final side = (size.width - AppSpacing.xl * 2).clamp(0.0, 420.0).toDouble();
    final multi = widget.notices.length > 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button (top-right, overlapping the card corner).
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4, bottom: 10),
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x55000000),
                            blurRadius: 12,
                            offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 26),
                  ),
                ),
              ),
              SizedBox(
                height: side,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.notices.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _NoticeCard(notice: widget.notices[i]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Controls: prev · dots · next.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (multi)
                    _ArrowButton(
                      icon: Icons.chevron_left_rounded,
                      enabled: _index > 0,
                      onTap: () => _go(_index - 1),
                    ),
                  const SizedBox(width: AppSpacing.xl),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.notices.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: AppDurations.base,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.winningTeal
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  if (multi)
                    _ArrowButton(
                      icon: Icons.chevron_right_rounded,
                      enabled: _index < widget.notices.length - 1,
                      onTap: () => _go(_index + 1),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.winningTeal,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.winningTeal.withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: -2,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeItem notice;
  const _NoticeCard({required this.notice});

  void _onTap() {
    if (notice.route != null) {
      Get.back(); // close the popup, then navigate in-app
      Get.toNamed(notice.route!);
    } else if (notice.url != null) {
      Get.back();
      AppLinks.open(notice.url!);
    }
  }

  bool get _isNetwork =>
      notice.image.startsWith('http://') || notice.image.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        // The padding + border form the frame "outside" the (square) image.
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: notice.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.18), width: 1.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x55000000),
                blurRadius: 24,
                offset: Offset(0, 10)),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1, // square image
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: _isNetwork
                ? Image.network(
                    notice.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, child, p) => p == null
                        ? child
                        : const _NoticeFallback(loading: true),
                    errorBuilder: (_, __, ___) => const _NoticeFallback(),
                  )
                : Image.asset(
                    notice.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _NoticeFallback(),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Shown while a notice image loads or if it fails — keeps the card looking
/// intentional instead of broken.
class _NoticeFallback extends StatelessWidget {
  final bool loading;
  const _NoticeFallback({this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Icon(Icons.image_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.5)),
    );
  }
}
