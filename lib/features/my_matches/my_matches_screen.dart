import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/services/session_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';
import '../matches/match_list_screen.dart';

/// Shows matches the user has joined.
class MyMatchesScreen extends StatelessWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;
    return Scaffold(
      appBar: AppBar(title: const Text('My Matches')),
      body: Obx(() {
        final joined = session.joinedMatches;
        if (joined.isEmpty) {
          return const EmptyState(
            icon: Icons.sports_esports_outlined,
            title: 'Join a match to see it here',
            hint: 'Your joined matches will appear here',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: joined.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) {
            final m = joined[i];
            return Column(
              children: [
                MatchListCard(
                  match: m,
                  onTap: () => Get.toNamed(AppRoutes.matchInfo, arguments: m),
                ),
                if (m.roomId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.meeting_room_outlined,
                              color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                              'Room ID: ${m.roomId}  •  Pass: ${m.roomPassword}',
                              style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }),
    );
  }
}
