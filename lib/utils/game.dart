import 'dart:math';

List<String> generateDeck() {
  const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
  const ranks = [
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    'J',
    'Q',
    'K',
    'A'
  ];
  List<String> deck = [];
  for (final suit in suits) {
    for (final rank in ranks) {
      deck.add("assets/images/card_${suit}_$rank.png");
    }
  }
  deck.add("assets/images/card_joker_red.png");
  print({
    "hijra:":deck,
  });
  return deck;
}

List<String> shuffleDeck(List<String> deck) {
  for (int i = deck.length - 1; i > 0; i--) {
    final j = Random().nextInt(i + 1);
    final temp = deck[i];
    deck[i] = deck[j];
    deck[j] = temp;
  }
  print({
    "hijra-sshuffle:": deck,
  });
  return deck.sublist(0, 7);
}
