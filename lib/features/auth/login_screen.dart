import 'package:flutter/material.dart';
import '../../app/core/app_sheets.dart';
import '../../app/core/app_toast.dart';
import 'package:get/get.dart';
import '../../app/core/app_constants.dart';
import '../../app/data/services/session_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/auth_backdrop.dart';
import '../../app/widgets/auth_field.dart';
import '../../app/widgets/glass.dart';
import '../../app/widgets/primary_button.dart';

class LoginController extends GetxController {
  final identifier = TextEditingController();
  final password = TextEditingController();
  final loading = false.obs;

  @override
  void onClose() {
    identifier.dispose();
    password.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (identifier.text.trim().isEmpty || password.text.isEmpty) {
      AppToast.error('Enter your phone/email and password');
      return;
    }
    loading.value = true;
    await SessionService.to.login(identifier.text.trim(), password.text);
    loading.value = false;
    Get.offAllNamed(AppRoutes.shell);
  }
}

void _openForgotPassword() {
  AppSheet.show(
    title: 'Reset Password',
    subtitle: 'Enter your account phone or email and we’ll send a reset link.',
    child: const _ForgotPasswordSheet(),
  );
}

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _identifier = TextEditingController();
  final _sending = false.obs;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identifier.text.trim().isEmpty) {
      AppToast.warning('Enter your phone or email first');
      return;
    }
    _sending.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _sending.value = false;
    Get.back();
    AppToast.success('Reset link sent to ${_identifier.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthField(
          label: 'Phone or Email',
          hint: 'Enter your phone or email',
          icon: Icons.person_outline,
          controller: _identifier,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: _submit,
        ),
        const SizedBox(height: AppSpacing.lg),
        Obx(() => PrimaryButton(
              label: 'Send Reset Link',
              icon: Icons.send_rounded,
              loading: _sending.value,
              onPressed: _submit,
            )),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LoginController());
    return Scaffold(
      body: Stack(
        children: [
          const AuthBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GlassSurface(
                  blur: 22,
                  opacity: 0.5,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xxl,
                      AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'brand-logo',
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            // Rounded-square frame matching the (square) logo so
                            // its corners never poke outside the border ring.
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 30),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Image.asset(AppConstants.logo,
                                width: 96, height: 96, cacheWidth: 280),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text('Welcome Back', style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Sign in to continue',
                          style: AppTextStyles.body1
                              .copyWith(color: context.cTextDim)),
                      const SizedBox(height: AppSpacing.xxl),
                      AuthField(
                        label: 'Phone or Email',
                        hint: 'Enter your phone or email',
                        icon: Icons.person_outline,
                        controller: c.identifier,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AuthField(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        controller: c.password,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: c.submit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openForgotPassword,
                          child: Text('Forgot password?',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Obx(() => PrimaryButton(
                            label: 'Login',
                            loading: c.loading.value,
                            onPressed: c.submit,
                          )),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: AppTextStyles.body2
                                  .copyWith(color: context.cTextDim)),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: Text('Register',
                                style: AppTextStyles.title.copyWith(
                                    color: AppColors.primary, fontSize: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Version ${AppConstants.appVersion}',
                          style: AppTextStyles.body2
                              .copyWith(color: context.cTextMuted)),
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
