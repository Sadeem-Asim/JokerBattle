import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

String removeCopy(String card) {
  card = '${card.split("-")[0]}.png';
  return card;
}

String addCopy(String card) {
  card = '${card.split(".")[0]}-Copy.png';
  return card;
}

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

class UpgradeClass {
  String imageUrl;
  int cost;
  bool isPurchased;

  UpgradeClass(
      {required this.imageUrl, required this.cost, required this.isPurchased});
}

List<UpgradeClass> generateDeckForUpgrade(
    List<String> purchaseCards, List<String> purchaseJokers) {
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
  List<UpgradeClass> deck = [];
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
      deck.add(UpgradeClass(
          imageUrl: "assets/images/card_${suit}_$rank.png",
          cost: cost,
          isPurchased: false));
    }
  }

  List<String> jokers = [
    'suit',
    'fake',
    'empty-bonus',
    'extrachange',
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

    deck.add(UpgradeClass(
        imageUrl: "assets/images/${jokers[i]}.png",
        cost: cost,
        isPurchased: false));
  }
  if (purchaseCards.length >= 1 || purchaseJokers.length >= 1) {
    purchaseCards = purchaseCards.map((card) => removeCopy(card)).toList();
    List<String> cards = purchaseCards + purchaseJokers;
    // print(cards);
    for (var purchase in cards) {
      var cardToUpdate = deck.firstWhere((card) => card.imageUrl == purchase);
      cardToUpdate.isPurchased = true;
    }
  }

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

List<Map<String, dynamic>> setJokerFirstScreenAssets(
    List<String> purchaseJokers) {
  List<Map<String, dynamic>> allAssets = [
    {
      "imageUrl": "assets/images/suit.png",
      'text': 'SUIT',
      'cost': 10,
      'additionalText': "Select A Card To Change Suit"
    },
    {
      "imageUrl": "assets/images/fake.png",
      'text': 'FAKE',
      'cost': 15,
      'additionalText': "Select A Card To Replace"
    },
    {
      "imageUrl": "assets/images/extrachange.png",
      'text': 'EXTRACHANGE',
      'cost': 20,
      'additionalText':
          "gives you an extra attempt to change the cards in your hand"
    },
    {
      "imageUrl": "assets/images/trump.png",
      'text': 'TRUMP',
      'cost': 20,
      'additionalText': "Select A Card To Replace"
    },
    {
      "imageUrl": "assets/images/empty-bonus.png",
      'text': 'EMPTYBONUS',
      'cost': 15,
      'additionalText':
          "adds to the result of your combo the amount of points for cards that were not in your combo."
    },
    {
      "imageUrl": "assets/images/hand-bonus.png",
      'text': 'HANDBONUS',
      'cost': 15,
      'additionalText':
          "get points for the remaining cards in your hand that you did not put on the table"
    },
    {
      "imageUrl": "assets/images/visor.png",
      'text': 'VISOR',
      'cost': 20,
      'additionalText': "see your opponent's current combo"
    },
    {
      "imageUrl": "assets/images/score.png",
      'text': 'SCORE',
      'cost': 30,
      'additionalText':
          "the point value of each card in your combo is increased by 2"
    },
    {
      "imageUrl": "assets/images/transformer.png",
      'text': 'TRANSFORMER',
      'cost': 25,
      'additionalText': "Select a card to transform"
    },
  ];
  List<Map<String, dynamic>> result = allAssets
      .where((asset) => purchaseJokers.contains(asset["imageUrl"]))
      .toList();
  // print(result);
  return result;
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
  List<UpgradeClass> upgradeScreenDeck = [];
  List<Map<String, dynamic>> jokerFirstScreenAssets = [];

  bool visor = false;
  bool score = false;
  bool handBonus = false;
  bool emptyBonus = false;
  bool? winStatus;
  int currentRound = 1;
  int noOfChips = 1000;
  int currentLevel = 1;
  int playerScore = 0;
  int aiScore = 0;
  int remainingDeckView = 3;
  void scoreX2() {
    score = true;
    purchaseJokers.removeWhere((joker) => joker == "assets/images/score.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void visorShow() {
    visor = true;
    purchaseJokers.removeWhere((joker) => joker == "assets/images/visor.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void handBonusShow() {
    handBonus = true;
    purchaseJokers
        .removeWhere((joker) => joker == "assets/images/hand-bonus.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void emptyBonusShow() {
    emptyBonus = true;
    purchaseJokers
        .removeWhere((joker) => joker == "assets/images/empty-bonus.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void jokerFake(String selectedCardToFake, String selectedCardToCopy) {
    selectedCardsFromThirdRow = [];
    int index = selectedCards.indexOf(selectedCardToFake);
    remainingDeckElements.add(selectedCards[index]);
    selectedCards[index] = addCopy(selectedCardToCopy);
    print(selectedCards);
    purchaseJokers.removeWhere((joker) => joker == "assets/images/fake.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void jokerSuit(String selectedCardToSuit, String selectedCardToCopy) {
    selectedCardsFromThirdRow = [];

    int index = selectedCards.indexOf(selectedCardToSuit);
    remainingDeckElements.add(selectedCardToSuit);
    selectedCards[index] = addCopy(selectedCardToCopy);
    purchaseJokers.removeWhere((joker) => joker == "assets/images/suit.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void extraChanges() {
    remainingDeckView++;
    purchaseJokers
        .removeWhere((joker) => joker == "assets/images/extrachanges.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void trump(String selectedCardToSwap, String selectedCardToCopy) {
    selectedCardsFromThirdRow = [];

    int index = selectedCards.indexOf(selectedCardToSwap);
    remainingDeckElements.add(selectedCardToSwap);
    remainingDeckElements.removeWhere((card) => card == selectedCardToCopy);
    selectedCards[index] = selectedCardToCopy;
    purchaseJokers.removeWhere((joker) => joker == "assets/images/trump.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void transform(String selectedCardToSwap, String selectedCardToCopy) {
    selectedCardsFromThirdRow = [];

    int index = selectedCards.indexOf(selectedCardToSwap);
    remainingDeckElements.add(selectedCardToSwap);
    selectedCards[index] = selectedCardToCopy;
    purchaseJokers
        .removeWhere((joker) => joker == "assets/images/transformer.png");
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  bool isCardSelected(String path) {
    return selectedCardsFromThirdRow.contains(path);
  }

  void unselectCard(String path) {
    if (selectedCardsFromThirdRow.contains(path)) {
      selectedCardsFromThirdRow.remove(path);
    }
    notifyListeners();
  }

  void addPurchasedCard(String path, int cost) {
    if (path.contains("card")) {
      if (noOfChips >= cost) {
        noOfChips -= cost;
        String suit = path.split('.')[0];
        String copy = '${suit}-Copy.png';
        purchaseCards.add(copy);
        var cardToUpdate =
            upgradeScreenDeck.firstWhere((card) => card.imageUrl == path);

        cardToUpdate.isPurchased = true;
      }
    } else {
      if (noOfChips >= cost) {
        if (purchaseJokers.length < 5) {
          noOfChips -= cost;
          purchaseJokers.add(path);
          jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
          var cardToUpdate =
              upgradeScreenDeck.firstWhere((card) => card.imageUrl == path);

          cardToUpdate.isPurchased = true;
        }
      }
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

  void swapFunctionality() {
    remainingDeckElements
        .removeWhere((card) => selectedCardsFromThirdRow.contains(card));
    for (int i = 0; i < selectedCardsFromThirdRow.length; i++) {
      var index = selectedCards.indexOf(selectedCardsFromThirdRow[i]);
      if (index != -1) {
        final j = Random().nextInt(i + 1);
        print(j);
        var temp = selectedCards[index];
        selectedCards[index] = remainingDeckElements[j];
        discardedDeckElements += [temp];
        remainingDeckElements
            .removeWhere((card) => card == remainingDeckElements[j]);
      }
    }
    selectedCardsFromThirdRow = [];
    remainingDeckView > 0 ? remainingDeckView-- : null;
    notifyListeners();
  }

  void addTenChipsOnWin() {
    if (currentRound > 1) {
      noOfChips += 10;
      currentRound = 1;
    }
    // incrementCurrentLevel();
    notifyListeners();
  }

  void incrementCurrentRound() {
    if (currentRound < 6) {
      // remainingDeckElements += selectedCards;
      selectedCards += shuffleDeck(remainingDeckElements).sublist(0, 5);
      selectedCardsForAi = shuffleAIDeck(remainingAiElements);
      remainingAiElements
          .removeWhere((card) => selectedCardsForAi.contains(card));
      remainingDeckElements.removeWhere((card) => selectedCards.contains(card));
      currentRound++;
    }
    visor = false;
    handBonus = false;
    score = false;
    emptyBonus = false;
    notifyListeners();
  }

  void incrementCurrentLevel() {
    currentLevel++;
    currentRound = 1;
    discardedDeckElements = [];
    remainingDeckElements = generateDeck();
    remainingDeckElements += purchaseCards;
    remainingAiElements = generateDeckForAI();
    selectedCards = shuffleDeck(remainingDeckElements);
    remainingDeckElements.removeWhere((card) => selectedCards.contains(card));
    selectedCardsForAi = shuffleAIDeck(remainingAiElements);
    remainingAiElements
        .removeWhere((card) => selectedCardsForAi.contains(card));
    remainingDeckView = 3;

    aiScore = 0;
    playerScore = 0;
    visor = false;
    handBonus = false;
    score = false;
    emptyBonus = false;
    notifyListeners();
  }

  String removeCopy(String card) {
    card = '${card.split("_")[0]}.png';
    return card;
  }

  void putCards() {
    visor = false;

    discardedDeckElements += selectedCardsFromThirdRow;
    purchaseCards
        .removeWhere((card) => selectedCardsFromThirdRow.contains(card));

    var cardsToUpdate = upgradeScreenDeck.where(
      (card) =>
          selectedCardsFromThirdRow.contains(addCopy(card.imageUrl)) &&
          card.isPurchased == true,
    );

    for (var card in cardsToUpdate) {
      card.isPurchased = false;
    }
    try {
      upgradeScreenDeck = generateDeckForUpgrade(purchaseCards, purchaseJokers);
    } catch (e) {
      print(e);
    }

    selectedCards
        .removeWhere((card) => selectedCardsFromThirdRow.contains(card));
    notifyListeners();
  }

  void setWindStatus(bool status) {
    winStatus = status;
    notifyListeners();
  }

  void selectCards(String path) {
    notifyListeners();
  }

  void selectCardFromThirdRow(String path) {
    if (selectedCardsFromThirdRow.length <= 6 &&
        !selectedCardsFromThirdRow.contains(path)) {
      selectedCardsFromThirdRow.add(path);
    }
    notifyListeners();
  }

  void removeSingleCard(String path) {}

  void removeCards() {
    visor = false;
    handBonus = false;
    score = false;
    emptyBonus = false;
    selectedCardsFromThirdRow = [];
    notifyListeners();
  }

  void removeCardsOnGameClick() async {
    visor = false;
    handBonus = false;
    score = false;
    emptyBonus = false;

    selectedCards = [];
    selectedCardsFromThirdRow = [];
    selectedCardToSwap = [];
    currentRound = 1;
    currentLevel = 1;
    playerScore = 0;
    aiScore = 0;
    remainingDeckView = 3;

    discardedDeckElements = [];
    remainingDeckElements = generateDeck();
    remainingDeckElements += purchaseCards;
    remainingAiElements = generateDeckForAI();
    selectedCards = shuffleDeck(remainingDeckElements);
    remainingDeckElements.removeWhere((card) => selectedCards.contains(card));
    selectedCardsForAi = shuffleAIDeck(remainingAiElements);
    remainingAiElements
        .removeWhere((card) => selectedCardsForAi.contains(card));
    upgradeScreenDeck = generateDeckForUpgrade(purchaseCards, purchaseJokers);
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void removeCardsOnContinueClick() async {
    visor = false;
    handBonus = false;
    score = false;
    emptyBonus = false;

    selectedCards = [];
    selectedCardsFromThirdRow = [];
    selectedCardToSwap = [];
    currentRound = 1;
    remainingDeckView = 3;
    // currentLevel = 1;
    playerScore = 0;
    aiScore = 0;
    discardedDeckElements = [];
    remainingDeckElements = generateDeck();
    remainingDeckElements += purchaseCards;
    remainingAiElements = generateDeckForAI();
    selectedCards = shuffleDeck(remainingDeckElements);
    remainingDeckElements.removeWhere((card) => selectedCards.contains(card));
    selectedCardsForAi = shuffleAIDeck(remainingAiElements);
    remainingAiElements
        .removeWhere((card) => selectedCardsForAi.contains(card));
    upgradeScreenDeck = generateDeckForUpgrade(purchaseCards, purchaseJokers);
    jokerFirstScreenAssets = setJokerFirstScreenAssets(purchaseJokers);
    notifyListeners();
  }

  void updateChipsInProvider(
      int noOFChips, int level, List<String> jokers, List<String> cards) {
    noOfChips = noOFChips;
    currentLevel = level;
    purchaseCards = cards;
    purchaseJokers = jokers;
  }

  void lose() {
    currentRound = 1;
    currentLevel = 1;
    playerScore = 0;
    aiScore = 0;
    noOfChips = 0;
    purchaseCards = [];
    purchaseJokers = [];
  }
}
