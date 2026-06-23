import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/battle.dart';

class BattleLogWidget extends StatelessWidget {
  final List<BattleLogEntry> logs;
  final ScrollController? scrollController;

  const BattleLogWidget({super.key, required this.logs, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            log.displayText,
            style: TextStyle(
              color: log.isImportant
                  ? AppTheme.accentColor
                  : _getLogColor(log.action),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }

  Color _getLogColor(String action) {
    if (action.contains('击破') || action.contains('阵亡')) {
      return AppTheme.dangerColor;
    }
    if (action.contains('眩晕') ||
        action.contains('灼烧') ||
        action.contains('中毒')) {
      return Colors.orange;
    }
    if (action.contains('恢复') || action.contains('鼓舞')) {
      return AppTheme.successColor;
    }
    if (action.contains('未命中')) {
      return AppTheme.textSecondaryColor;
    }
    return AppTheme.textColor;
  }
}
