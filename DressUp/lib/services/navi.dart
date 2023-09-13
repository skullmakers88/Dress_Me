import 'package:flutter/cupertino.dart';

class CustomCupertinoTabBar extends CupertinoTabBar {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomCupertinoTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : super(
    items: items.map((item) {
      return BottomNavigationBarItem(
        icon: GestureDetector(
          onTap: () {
            // Check if the tapped item is already selected
            if (currentIndex == items.indexOf(item)) {
              // If it is, set the selected index to -1 to close the current page
              onTap(-1);
            } else {
              // Otherwise, select the tapped item as usual
              onTap(items.indexOf(item));
            }
          },
          child: item.icon,
        ),
      );
    }).toList(),
  );
}
