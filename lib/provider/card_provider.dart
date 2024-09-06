import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/utils/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/utils/game.dart';
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
  // deck.add("assets/images/card_joker_red.png");
  return deck;
}

List<Map> generateDeckForUpgrade() {
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
  List<Map> deck = [];
  for (final suit in suits) {
    for (final rank in ranks) {
      var cost = 5;
      if (rank == "02" || rank == "03" || rank == "04") {
        cost = 5;
      } else if (rank == "05" || rank == "06" || rank == "07") {
        cost = 8;
      } else if (rank == "09" || rank == "10") {
        cost = 10;
      } else if (rank == "J") {
        cost = 13;
      } else if (rank == "Q") {
        cost = 15;
      } else if (rank == "K") {
        cost = 17;
      } else if (rank == "A") {
        cost = 20;
      }
      deck.add(
          {"imageUrl": "assets/images/card_${suit}_$rank.png", "cost": cost});
    }
  }

  List<String> jokers = [
    'suit',
    'fake',
    'empty-bonus',
    'extrachange(2)',
    'hand-bonus',
    'score',
    'transformer',
    "trump",
    "visor"
  ];

  for (int i = 0; i < jokers.length; i++) {
    var cost = 15;

    if (jokers[i] == "suit") {
      cost = 10;
    } else if (jokers[i] == "extrachange(2)") {
      cost = 20;
    } else if (jokers[i] == "trump") {
      cost = 20;
    } else if (jokers[i] == "visor") {
      cost = 20;
    } else if (jokers[i] == "score") {
      cost = 30;
    } else if (jokers[i] == "transformer") {
      cost = 25;
    }
    deck.add({"imageUrl": "assets/images/${jokers[i]}.png", "cost": cost});
  }
  print({"deck": deck});
  return deck;
}

List<String> generateDeckForAI() {
  const suits = [
    'clubs',
    'spades',
    'hearts',
    'diamonds',
  ];
  const ranks = [
    '09',
    '10',
    'J',
    'Q',
    'K',
    'A',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
  ];
  List<String> deck = [];
  for (final suit in suits) {
    for (final rank in ranks) {
      deck.add("assets/images/card_${suit}_$rank.png");
    }
  }
  deck.add("assets/images/card_joker_red.png");
  // print({
  //   "hijra:": deck,
  // });
  return deck;
}

List<String> shuffleDeck(List<String> deck) {
  for (int i = deck.length - 1; i > 0; i--) {
    final j = Random().nextInt(i + 1);
    final temp = deck[i];
    deck[i] = deck[j];
    deck[j] = temp;
  }
  return deck.sublist(0, 7);
}

List<String> shuffleAIDeck(List<String> deck) {
  for (int i = deck.length - 1; i > 0; i--) {
    final j = Random().nextInt(i + 1);
    final temp = deck[i];
    deck[i] = deck[j];
    deck[j] = temp;
  }

  return deck.sublist(0, 5);
}

class CardsProvider with ChangeNotifier {
  List<String> selectedCards = [];
  List<String> selectedCardsFromThirdRow = [];
  List<String> remainingDeckElements = [];
  List<String> remainingAiElements = [];
  List<String> discardedDeckElements = [];
  List<String> selectedCardsForAi = [];
  List<String> shuffleDeckElements = [];
  List<String> selectedCardToSwap = [];
  List<String> purchaseCards = [];
  List<String> purchaseJokers = [];
  List<Map> upgradeScreenDeck = [];

  bool isFlipped = false;
  bool? winStatus;
  int currentRound = 1;
  int noOfChips = 100;
  int currentLevel = 1;
  int playerScore = 0;
  int aiScore = 0;

  bool isCardSelected(String path) {
    return selectedCardsFromThirdRow.contains(path);
  }

  // Function to unselect a card
  void unselectCard(String path) {
    if (selectedCardsFromThirdRow.contains(path)) {
      selectedCardsFromThirdRow.remove(path);
    }
    notifyListeners();
  }

  void addPurchasedCard(String path, int cost) {
    if (noOfChips >= cost) {
      noOfChips -= cost;
      print(noOfChips);
      purchaseCards.add(path);
    }
    notifyListeners();
  }

  void addAiScore(int points) {
    aiScore += points;
    notifyListeners();
  }

  void setAiScore(int points) {
    aiScore = points;
    notifyListeners();
  }

  void addPlayerScore(int points) {
    playerScore += points;
    notifyListeners();
  }

  void setPlayerScore(int points) {
    playerScore = points;
    notifyListeners();
  }

  void selectCardToSwap(String Path) {
    selectedCardToSwap.contains(Path)
        ? {
            selectedCardToSwap.remove(Path),
            print({
              "harami-swap-remove": {
                "path": Path,
                "selectedCardToSwap.length": selectedCardToSwap.length,
                "selectedCardToSwap": selectedCardToSwap
              }
            })
          }
        : selectedCardsFromThirdRow.length == 5 && selectedCardToSwap.length < 1
            ? {
                selectedCardToSwap.add(Path),
                print({
                  "harami-swap-add": {
                    "path": Path,
                    "selectedCardToSwap.length": selectedCardToSwap.length,
                    "selectedCardsFromThrdorow.length":
                        selectedCardsFromThirdRow.length,
                    "selectedCardToSwap": selectedCardToSwap
                  }
                }),
              }
            : null;

    notifyListeners();
  }

  void removeCardToSwap(String Path) {
    selectedCardToSwap.contains(Path) ? selectedCardToSwap.remove(Path) : null;
    notifyListeners();
  }

  void swapFunctionality() {
    for (int i = 0; i < selectedCardsFromThirdRow.length; i++) {
      var index = selectedCards.indexOf(selectedCardsFromThirdRow[i]);
      if (index != -1) {
        final j = Random().nextInt(i + 1);
        print(j);
        var temp = selectedCards[index];
        selectedCards[index] = remainingDeckElements[j];
        remainingDeckElements[j] = temp;
      }
    }
    selectedCardsFromThirdRow = [];
    notifyListeners();
  }

  void addTenChipsOnWin() {
    noOfChips += 10;
    currentRound = 1;
    // incrementCurrentLevel();
    notifyListeners();
  }

  void incrementCurrentRound() {
    if (currentRound < 6) {
      remainingDeckElements += selectedCards;
      selectedCards = shuffleDeck(remainingDeckElements);
      selectedCardsForAi = shuffleAIDeck(remainingAiElements);
      remainingAiElements
          .removeWhere((card) => selectedCardsForAi.contains(card));
      remainingDeckElements.removeWhere((card) => selectedCards.contains(card));
      currentRound++;
    }
    notifyListeners();
  }

  void incrementCurrentLevel() {
    if (currentRound >= 5) {
      currentLevel++;
      currentRound = 1;
      discardedDeckElements = [];
      remainingDeckElements = generateDeck();
      remainingAiElements = generateDeckForAI();
      selectedCards = shuffleDeck(remainingDeckElements);
      remainingDeckElements.removeWhere((card) => selectedCards.contains(card));
      selectedCardsForAi = shuffleAIDeck(remainingAiElements);
      remainingAiElements
          .removeWhere((card) => selectedCardsForAi.contains(card));
    }
    aiScore = 0;
    playerScore = 0;
    notifyListeners();
  }

  void setCurrentRound(int value) {
    currentRound = value;
    if (value == 1) {
      selectedCardsFromThirdRow = [];
    }
    notifyListeners();
  }

  void putCards() {
    discardedDeckElements += selectedCardsFromThirdRow;
    selectedCards
        .removeWhere((card) => selectedCardsFromThirdRow.contains(card));
    notifyListeners();
  }

  void setWindStatus(bool status) {
    winStatus = status;
    notifyListeners();
  }

  void shuffleDeckElement(deck) {
    shuffleDeckElements = shuffleDeck(deck);
    selectedCards = shuffleDeckElements;
    notifyListeners();
  }

  void selectCards(String path) {
    if ((selectedCards.length < 7) && !selectedCards.contains(path)) {
      selectedCards.add(path);
    }
    notifyListeners();
  }

  void addMultipleCards(List<String> deck) {
    selectedCards = deck;
    notifyListeners();
  }

  void selectCardsForSecondRow(List<String> selectedCards) {
    selectedCards = selectedCards;
    notifyListeners();
  }

  void selectCardFromThirdRow(String path) {
    if (selectedCardsFromThirdRow.length <= 6 &&
        !selectedCardsFromThirdRow.contains(path)) {
      selectedCardsFromThirdRow.add(path);
    }
    notifyListeners();
  }

  void removeSingleCard(String path) {
    selectedCards.remove(path);
    selectedCards.remove(path);
    notifyListeners();
  }

  void removeCards() {
    selectedCardsFromThirdRow = [];
    notifyListeners();
  }

  void removeCardsOnGameClick() {
    selectedCards = [];
    selectedCardsFromThirdRow = [];
    selectedCardToSwap = [];
    currentRound = 1;
    currentLevel = 1;
    playerScore = 0;
    aiScore = 0;
    discardedDeckElements = [];
    remainingDeckElements = generateDeck();
    remainingAiElements = generateDeckForAI();
    selectedCards = shuffleDeck(remainingDeckElements);
    remainingDeckElements.removeWhere((card) => selectedCards.contains(card));
    selectedCardsForAi = shuffleAIDeck(remainingAiElements);
    remainingAiElements
        .removeWhere((card) => selectedCardsForAi.contains(card));

    upgradeScreenDeck = generateDeckForUpgrade();
    updateChipsInProvider();
    notifyListeners();
  }

  Future<void> updateChipsInProvider() async {
    var box = await Hive.openBox('noOfChips');
    var N_O_C = await box.get('noOfChips');
    noOfChips = N_O_C;
  }

  Future<void> updateChipsInHive() async {
    var box = await Hive.openBox('noOfChips');
    await box.put('noOfChips', noOfChips);
  }
}
