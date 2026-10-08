import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final navIndexProvider =
    NotifierProvider<NavIndexNotifier, int>(NavIndexNotifier.new);