import 'package:flutter/material.dart';
import 'package:pdfer/src/features/feature_item.dart';
import 'package:pdfer/src/file_selection/file_selection_view.dart';

/// Displays detailed information about a FeatureItem.
class FeatureItemDetailsView extends StatelessWidget {
  const FeatureItemDetailsView({super.key, required this.featureItem});

  static const routeName = '/feature_item';

  final FeatureItem featureItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(featureItem.icon),
            const SizedBox(width: 16),
            Text(featureItem.name),
          ],
        ),
      ),
      body: Center(child: _buildContent(featureItem)),
    );
  }

  Widget _buildContent(FeatureItem featureItem) {
    switch (featureItem.name) {
      case 'Split':
      case 'Rotate':
      case 'Delete':
        return FileSelectionView(featureItem: featureItem);
      case 'Merge':
        return FileSelectionView(featureItem: featureItem, allowMultiple: true);
      default:
        return const Text('Error, feature not found');
    }
  }
}
