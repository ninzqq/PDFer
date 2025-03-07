import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'feature_item.dart';
import 'feature_item_details_view.dart';

/// Displays a list of FeatureItems.
class FeatureItemListView extends StatelessWidget {
  const FeatureItemListView({
    super.key,
    this.items = const [
      FeatureItem('Split', 'Split PDF into two files', Icons.call_split),
      FeatureItem(
          'Merge', 'Merge multiple PDFs into one file', Icons.merge_type),
      FeatureItem('Rotate', 'Rotate PDF', Icons.rotate_left),
      FeatureItem('Delete', 'Delete a page or pages from PDF', Icons.cut),
    ],
  });

  static const routeName = '/';

  final List<FeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Features'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView.builder(
            // Providing a restorationId allows the ListView to restore the
            // scroll position when a user leaves and returns to the app after it
            // has been killed while running in the background.
            restorationId: 'featureItemListView',
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = items[index];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                    title: Text(item.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text(item.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                    leading: CircleAvatar(
                      child: Icon(item.icon),
                    ),
                    tileColor: Theme.of(context).colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onTap: () {
                      // Navigate to the details page. If the user leaves and returns to
                      // the app after it has been killed while running in the
                      // background, the navigation stack is restored.
                      Navigator.pushNamed(
                        context,
                        FeatureItemDetailsView.routeName,
                        arguments: item,
                      );
                    }),
              );
            },
          ),
        ),
      ),
    );
  }
}
