import 'package:flutter/material.dart';

class CaptureStageNavigation extends StatelessWidget {
  const CaptureStageNavigation({
    super.key,
    this.previousLabel,
    this.previousAction,
    this.nextLabel,
    this.nextAction,
  });

  final String? previousLabel;
  final VoidCallback? previousAction;
  final String? nextLabel;
  final VoidCallback? nextAction;

  @override
  Widget build(BuildContext context) {
    if (previousLabel == null && nextLabel == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (previousLabel != null)
              OutlinedButton.icon(
                onPressed: previousAction,
                icon: const Icon(Icons.arrow_back_outlined),
                label: Text(previousLabel!),
              ),
            if (nextLabel != null)
              FilledButton.icon(
                onPressed: nextAction,
                icon: const Icon(Icons.arrow_forward_outlined),
                label: Text(nextLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
