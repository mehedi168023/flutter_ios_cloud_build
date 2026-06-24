import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/mock/mock_data.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';

class MatchRulesController extends GetxController {
  final selected = 0.obs;
}

/// Standalone Match Rules viewer with horizontally-scrollable mode chips.
class MatchRulesScreen extends StatelessWidget {
  const MatchRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MatchRulesController());
    const modes = MockData.gameModes;

    return Scaffold(
      appBar: AppBar(title: const Text('Match Rules')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child:
                Text('Pick a mode', style: TextStyle(color: context.cTextDim)),
          ),
          SizedBox(
            height: 48,
            child: Obx(() {
              // Read the observable synchronously here so GetX registers the
              // dependency (itemBuilder runs lazily, outside the Obx scope).
              final selected = c.selected.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: modes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final active = selected == i;
                  return GestureDetector(
                    onTap: () => c.selected.value = i,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : context.cSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                active ? AppColors.primary : context.cBorder),
                      ),
                      child: Text(modes[i].title,
                          style: AppTextStyles.title.copyWith(
                              fontSize: 13,
                              color: active ? Colors.white : context.cTextDim)),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final mode = modes[c.selected.value];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mode.title,
                          style: AppTextStyles.title
                              .copyWith(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Text(MockData.rulesForMode(mode.key),
                          style: AppTextStyles.body1.copyWith(height: 1.7)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
