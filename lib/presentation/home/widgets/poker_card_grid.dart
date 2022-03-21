import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/rooms/models/poker_card.dart';
import '../../../injectable/injectable.dart';
import '../selected_card_notifier.dart';
import 'poker_card_widget.dart';

final _cardProvider = Provider<List<PokerCard>>((ref) {
  return ['?', '1', '2', '3', '5', '8', '13'];
});

final _selectedCardProvider =
    StateNotifierProvider<SelectedCardNotifier, PokerCard?>(
  (ref) => getIt<SelectedCardNotifier>(param1: ref),
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
    ref.read(_selectedCardProvider.notifier).listenOnChanges();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(_cardProvider);
    final selectedCard = ref.watch(_selectedCardProvider);
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

  Widget _buildCard(PokerCard card, {required bool highlighted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: PokerCardWidget(
        card: card,
        highlighted: highlighted,
        onTapped: (_) {
          ref.read(_selectedCardProvider.notifier).selectCard(card);
        },
      ),
    );
  }
}
