import 'package:flutter/material.dart';
import '../../app/core/app_toast.dart';
import 'package:get/get.dart';
import '../../app/core/app_constants.dart';
import '../../app/data/services/session_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/auth_field.dart';
import '../../app/widgets/primary_button.dart';

class RegisterController extends GetxController {
  final name = TextEditingController();
  final identifier = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final refer = TextEditingController();
  final loading = false.obs;

  @override
  void onClose() {
    name.dispose();
    identifier.dispose();
    password.dispose();
    confirm.dispose();
    refer.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (name.text.trim().isEmpty ||
        identifier.text.trim().isEmpty ||
        password.text.isEmpty) {
      AppToast.error('Please fill all required fields');
      return;
    }
    if (password.text != confirm.text) {
      AppToast.error('Passwords do not match');
      return;
    }
    loading.value = true;
    await SessionService.to
        .register(name.text.trim(), identifier.text.trim(), password.text);
    loading.value = false;
    Get.offAllNamed(AppRoutes.shell);
    AppToast.success('Account created successfully!');
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(RegisterController());
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Image.asset(AppConstants.logo,
                  width: 80, height: 80, cacheWidth: 240),
              const SizedBox(height: 13),
              AuthField(
                  label: 'Full Name',
                  hint: 'Enter your name',
                  icon: Icons.person_outline,
                  controller: c.name),
              const SizedBox(height: 11),
              AuthField(
                  label: 'Phone or Email',
                  hint: 'Enter your phone or email',
                  icon: Icons.alternate_email,
                  controller: c.identifier,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 11),
              AuthField(
                label: 'Password',
                hint: 'Enter password',
                icon: Icons.lock_outline,
                controller: c.password,
                isPassword: true,
              ),
              const SizedBox(height: 11),
              AuthField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  icon: Icons.lock_outline,
                  controller: c.confirm,
                  isPassword: true),
              const SizedBox(height: 11),
              AuthField(
                  label: 'Refer Code',
                  hint: 'Enter refer code if any',
                  icon: Icons.card_giftcard_outlined,
                  controller: c.refer,
                  textInputAction: TextInputAction.done,
                  onSubmitted: c.submit),
              const SizedBox(height: 11),
              Obx(() => PrimaryButton(
                  label: 'Register',
                  loading: c.loading.value,
                  onPressed: c.submit)),
              const SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ',
                      style: AppTextStyles.body2
                          .copyWith(color: context.cTextDim)),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text('Login',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.primary, fontSize: 15)),
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
