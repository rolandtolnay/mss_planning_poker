import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../injectable/injectable.dart';
import '../participant_value_notifier.dart';
import 'poker_card_widget.dart';

final _cardProvider = Provider<List<String>>((ref) {
  return ['?', '1', '2', '3', '5', '8', '13'];
});

final pcpValueProvider =
    StateNotifierProvider<ParticipantValueNotifier, String?>(
  (ref) => getIt<ParticipantValueNotifier>(param1: ref),
);

class PokerCardGrid extends ConsumerStatefulWidget {
  const PokerCardGrid({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PokerCardGridState();
}

class _PokerCardGridState extends ConsumerState<PokerCardGrid> {
  @override
  void initState() {
    super.initState();
    ref.read(pcpValueProvider.notifier).listenOnChanges();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(_cardProvider);
    final selectedCard = ref.watch(pcpValueProvider);
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: cards
                .map((c) => _buildCard(c, highlighted: c == selectedCard))
                .toList()),
      ),
    );
  }

  Widget _buildCard(String value, {required bool highlighted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: PokerCardWidget(
        value: value,
        highlighted: highlighted,
        onTapped: (_) => ref.read(pcpValueProvider.notifier).setValue(value),
      ),
    );
  }
}
