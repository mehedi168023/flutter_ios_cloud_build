import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Labeled text field with a leading icon and a self-managed password
/// eye-toggle. The label starts as an in-field placeholder and smoothly
/// animates up onto the border outline when the field is focused or filled
/// (Material floating-label). Stateful so toggling visibility never rebuilds
/// the parent (avoids focus/cursor glitches while typing).
class AuthField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool locked;
  final TextInputType? keyboardType;

  /// Keyboard action button. Defaults to "next" so multi-field forms advance
  /// focus automatically; set [TextInputAction.done] on the last field.
  final TextInputAction textInputAction;

  /// Called when a completion action (done/go) is pressed — wire this to the
  /// form's submit on the last field.
  final VoidCallback? onSubmitted;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.locked = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    Widget? suffix;
    if (widget.locked) {
      suffix = Icon(Icons.lock_outline, color: context.cTextMuted, size: 18);
    } else if (widget.isPassword) {
      suffix = IconButton(
        splashRadius: 20,
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: context.cTextDim,
        ),
      );
    }

    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      enabled: !widget.locked,
      keyboardType: widget.keyboardType,
      // "next" advances focus to the next field automatically; "done"/"go"
      // fire onSubmitted. (Leaving onEditingComplete unset preserves Flutter's
      // default nextFocus() behavior for the "next" action.)
      textInputAction: widget.textInputAction,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      cursorColor: AppColors.primary,
      style: AppTextStyles.body1.copyWith(color: textColor, fontSize: 15),
      decoration: InputDecoration(
        // Floating label: shows inside as a placeholder, then animates up onto
        // the outline when focused/filled. The hint appears once it has risen.
        labelText: widget.label,
        hintText: widget.hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle:
            AppTextStyles.body1.copyWith(color: context.cTextDim, fontSize: 15),
        floatingLabelStyle: AppTextStyles.title.copyWith(
          color: widget.locked ? context.cTextMuted : AppColors.primary,
          fontSize: 13.5,
        ),
        hintStyle: AppTextStyles.body1
            .copyWith(color: context.cTextMuted, fontSize: 14),
        filled: true,
        fillColor: widget.locked
            ? context.cSurface.withValues(alpha: 0.4)
            : context.cSurfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: Icon(widget.icon, color: context.cTextDim, size: 22),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.cBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.cBorder),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.cBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
