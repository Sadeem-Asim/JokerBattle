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
  List<String> selectedCardsForSecondRow = [];
  List<String> selectedCardsFromThirdRow = [];
  List<String> remainingDeckElements = [];
  List<String> remainingAiElements = [];
  List<String> discardedDeckElements = [];
  List<String> selectedCardsForAi = [];
  List<String> shuffleDeckElements = [];
  List<String> selectedCardToSwap = [];
  List<String> purchaseCards = [];
  List<String> purchaseJokers = [];
  bool isFlipped = false;
  bool? winStatus;
  int currentRound = 1;
  int noOfChips = 0;
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

    notifyListeners(); // Notify listeners about the change
  }

  Future<void> addPurchasedCard(String path, int cost) async {
    var box = await Hive.openBox('noOfChips');
    var noOFChips = await box.get('noOfChips');
    if (noOFChips > cost) {
      await box.put("noOfChips", "${noOFChips - cost}");
      noOfChips = noOFChips - cost;
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
        var temp = selectedCards[index];
        selectedCards[index] = remainingDeckElements[j];
        remainingAiElements[j] = temp;
        selectedCardsFromThirdRow = [];
      }
    }
    selectedCardsFromThirdRow = [];
    notifyListeners();

    notifyListeners();
  }

  void remainingDeck(deck) {
    remainingDeckElements =
        deck.where((element) => !selectedCards.contains(element)).toList();
    print({"remainingDeckElements": remainingDeckElements.length});
    notifyListeners();
  }

  Future<void> addTenChipsOnWin() async {
    var box = await Hive.openBox('noOfChips');
    var noOFChips = await box.get('noOfChips');
    noOFChips += 10;
    await box.put('noOfChips', noOFChips);
    noOfChips = noOFChips;
    currentRound = 1;
    incrementCurrentLevel();

    notifyListeners();
  }

  void incrementCurrentRound() {
    if (currentRound < 6) {
      currentRound++;
      selectedCardsForAi = shuffleAIDeck(remainingAiElements);
      remainingAiElements
          .removeWhere((card) => selectedCardsForAi.contains(card));
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
      selectedCardsForSecondRow = shuffleDeck(remainingDeckElements);
      remainingDeckElements
          .removeWhere((card) => selectedCardsForSecondRow.contains(card));
      discardedDeckElements += selectedCardsForSecondRow;
      selectedCardsForAi = shuffleAIDeck(remainingAiElements);
      remainingAiElements
          .removeWhere((card) => selectedCardsForAi.contains(card));
    }
    notifyListeners();
  }

  void setCurrentRound(int value) {
    currentRound = value;
    if (value == 1) {
      selectedCardsFromThirdRow = [];
    }
    notifyListeners();
  }

  void setWindStatus(bool status) {
    winStatus = status;
    // print({"murgha": remainingDeckElements.length});
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
    selectedCardsForSecondRow = selectedCards;
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
    selectedCardsForSecondRow.remove(path);
    notifyListeners();
  }

  void removeCards() {
    discardedDeckElements += selectedCardsFromThirdRow;
    selectedCardsForSecondRow = [];
    selectedCardsFromThirdRow = [];
    selectedCardToSwap = [];
    notifyListeners();
  }

  void removeCardsOnGameClick() {
    selectedCardsForSecondRow = [];
    selectedCardsFromThirdRow = [];
    selectedCardToSwap = [];
    currentRound = 1;
    currentLevel = 1;
    playerScore = 0;
    aiScore = 0;
    discardedDeckElements = [];
    remainingDeckElements = generateDeck();
    remainingAiElements = generateDeckForAI();
    selectedCardsForSecondRow = shuffleDeck(remainingDeckElements);
    remainingDeckElements
        .removeWhere((card) => selectedCardsForSecondRow.contains(card));
    discardedDeckElements += selectedCardsForSecondRow;

    selectedCardsForAi = shuffleAIDeck(remainingAiElements);
    remainingAiElements
        .removeWhere((card) => selectedCardsForAi.contains(card));
    notifyListeners();
  }
}
