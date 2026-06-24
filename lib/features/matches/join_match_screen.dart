import 'package:flutter/material.dart';
import '../../app/core/app_toast.dart';
import 'package:get/get.dart';
import '../../app/data/models/match_model.dart';
import '../../app/data/services/session_service.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';
import '../../app/widgets/primary_button.dart';
import 'widgets/match_card.dart';

class JoinMatchController extends GetxController {
  final FfMatch match;
  JoinMatchController(this.match);

  final slotType = 0.obs; // 0 = Solo (1P), 1 = Duo (2P)
  final loading = false.obs;
  final List<TextEditingController> fields =
      List.generate(2, (_) => TextEditingController());

  int get slotCount => slotType.value == 0 ? 1 : 2;

  @override
  void onInit() {
    super.onInit();
    // Default the slot type to match the match's own type.
    slotType.value = match.type.toLowerCase() == 'duo' ? 1 : 0;
  }

  Future<void> join() async {
    final names = List.generate(slotCount, (i) => fields[i].text.trim());
    if (names.any((n) => n.isEmpty)) {
      AppToast.error('Enter all player in-game names');
      return;
    }
    loading.value = true;
    final ok = await SessionService.to.joinMatch(match, names);
    loading.value = false;
    if (ok) {
      Get.back();
      AppToast.success('Joined Successfully!');
    } else {
      AppToast.error('Failed to join.');
    }
  }

  @override
  void onClose() {
    for (final f in fields) {
      f.dispose();
    }
    super.onClose();
  }
}

class JoinMatchScreen extends StatelessWidget {
  const JoinMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final match = Get.arguments as FfMatch;
    final c = Get.put(JoinMatchController(match));

    return Scaffold(
      appBar: AppBar(title: const Text('Join Match')),
      bottomNavigationBar: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() => PrimaryButton(
              label: 'Join Match',
              icon: Icons.add_circle_outline,
              variant: ButtonVariant.green,
              loading: c.loading.value,
              onPressed: c.join,
            )),
      )),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          MatchInfoCard(match: match, showSlots: true, compact: true),
          const SizedBox(height: 13),
          const SectionHeader('SELECT SLOT TYPE'),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: [
                  _slotOption(context, c, 0, Icons.person, 'Solo', '1P'),
                  const SizedBox(width: 12),
                  _slotOption(context, c, 1, Icons.groups, 'Duo', '2P'),
                ],
              )),
          const SizedBox(height: 14),
          Obx(() => Row(
                children: [
                  const SectionHeader('PLAYER NAMES'),
                  const SizedBox(width: 10),
                  StatusPill(
                      text: '${c.slotCount} slot(s)',
                      color: AppColors.primary,
                      showDot: false),
                ],
              )),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: List.generate(
                    c.slotCount,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _playerField(context, c, i),
                        )),
              )),
        ],
      ),
    );
  }

  Widget _slotOption(BuildContext context, JoinMatchController c, int index,
      IconData icon, String label, String tag) {
    final active = c.slotType.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.slotType.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : context.cSurface,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: active ? AppColors.primary : context.cBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20, color: active ? Colors.white : context.cTextDim),
              const SizedBox(width: 10),
              Text(label,
                  style: AppTextStyles.title.copyWith(
                      fontSize: 15,
                      color: active ? Colors.white : context.cText)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag,
                    style: AppTextStyles.label
                        .copyWith(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playerField(BuildContext context, JoinMatchController c, int i) {
    return Container(
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cBorder),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${i + 1}',
                style: AppTextStyles.title
                    .copyWith(color: AppColors.primary, fontSize: 18)),
          ),
          Expanded(
            child: TextField(
              controller: c.fields[i],
              // Last slot submits the join; earlier slots advance to the next.
              textInputAction: i == c.slotCount - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: i == c.slotCount - 1 ? (_) => c.join() : null,
              style: AppTextStyles.body1.copyWith(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'In-game name',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
