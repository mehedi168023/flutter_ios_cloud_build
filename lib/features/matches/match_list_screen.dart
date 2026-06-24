import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/models/match_model.dart';
import '../../app/data/services/session_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';
import 'widgets/match_card.dart';

/// Lists the matches for the tapped game mode, or an empty state.
class MatchListScreen extends StatelessWidget {
  const MatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = Get.arguments as GameMode;
    final session = SessionService.to;

    return Scaffold(
      appBar: AppBar(title: Text(mode.title)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: session.refreshMatches,
        child: Obx(() {
          final list = session.matchesForMode(mode.key);
          if (list.isEmpty) {
            // Fills the viewport so the empty state stays centered on any screen
            // size while keeping pull-to-refresh available.
            return LayoutBuilder(
              builder: (context, constraints) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: const Center(
                      child: EmptyState(
                        icon: Icons.videogame_asset_outlined,
                        title: 'No matches available right now',
                        hint: 'Pull down to refresh',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => MatchListCard(
              match: list[i],
              onTap: () => Get.toNamed(AppRoutes.matchInfo, arguments: list[i]),
            ),
          );
        }),
      ),
    );
  }
}

/// Compact match row used in the list.
class MatchListCard extends StatelessWidget {
  final FfMatch match;
  final VoidCallback onTap;
  const MatchListCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(match.title,
                      style: AppTextStyles.title.copyWith(fontSize: 17))),
              StatusPill(
                  text: match.isJoined ? 'Joined' : 'Active',
                  color: AppColors.success),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(context, Icons.emoji_events, AppColors.gold,
                  '${match.prize.toInt()} TK'),
              const SizedBox(width: 10),
              _chip(context, Icons.my_location, AppColors.killRed,
                  '${match.perKill.toInt()} TK'),
              const SizedBox(width: 10),
              _chip(context, Icons.payments_outlined, AppColors.primary,
                  '${match.entryFee.toInt()} TK'),
            ],
          ),
          const SizedBox(height: 14),
          MatchProgressBar(match: match),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, Color color, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.cBgAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.cBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(text, style: AppTextStyles.label.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
