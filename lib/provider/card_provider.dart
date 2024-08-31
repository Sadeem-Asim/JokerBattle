import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/utils/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/utils/game.dart';

class CardsProvider with ChangeNotifier {
  List<String> selectedCards = [];
  List<String> selectedCardsForSecondRow = [];
  List<String> selectedCardsFromThirdRow = [];
  List<String> remainingDeckElements = [];
  List<String> shuffleDeckElements = [];
  List<String> selectedCardToSwap = [];
  bool? winStatus;
  int currentRound = 1;
  int noOfChips = 0;
  int currentLevel = 1;
  int playerScore = 0;
  int aiScore = 0;

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
    // print({"choocha1": shuffleElements});
    var index = selectedCards.indexOf(selectedCardToSwap[0]);
    print({"choocha2": remainingDeckElements.length, "index": index});
    if (index != -1) {
      selectedCards[index] = remainingDeckElements[index];
      selectedCardToSwap = [];
    }

    notifyListeners();
  }

  void remainingDeck(deck) {
    remainingDeckElements =
        deck.where((element) => !selectedCards.contains(element)).toList();
    print({"murgha": remainingDeckElements.length});
    notifyListeners();
  }

  Future<void> addTenChipsOnWin() async {
    var box = await Hive.openBox('noOfChips');
    var noOFChips = await box.get('noOfChips');
    noOFChips += 10;
    await box.put('noOfChips', noOFChips);
    noOfChips = noOFChips;
    notifyListeners();
  }

  void incrementCurrentRound() {
    if (currentRound < 6) {
      currentRound++;
    }
    // print({"murgha": remainingDeckElements.length});
    notifyListeners();
  }

  void incrementCurrentLevel() {
    if (currentRound > 5) {
      currentLevel++;
    }
    // print({"murgha": remainingDeckElements.length});
    notifyListeners();
  }

  void setCurrentRound(int value) {
    currentRound = value;
    if (value == 1) {
      selectedCardsFromThirdRow = [];
    }
    ;
    // print({"murgha": remainingDeckElements.length});
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

    print({"murgha": shuffleDeckElements.length});
    notifyListeners();
  }

  // List<String> get selectedCards;

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
    // if (selectedCards.length <= 4 && !selectedCards.contains(path)) {
    //   selectedCards.add(path);
    // }
    selectedCardsForSecondRow = selectedCards;
    notifyListeners();
  }

  void selectCardFromThirdRow(String path) {
    if (selectedCardsFromThirdRow.length <= 4 &&
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
    // selectedCards = [];
    selectedCardsForSecondRow = [];
    selectedCardsFromThirdRow = [];

    // List<String> selectedCards = [];
    // List<String> selectedCardsForSecondRow = [];
    // List<String> selectedCardsFromThirdRow = [];
    // List<String> remainingDeckElements = [];
    // List<String> shuffleDeckElements = [];
    selectedCardToSwap = [];
    notifyListeners();
  }

  void removeCardsOnGameClick() {
    // selectedCards = [];
    selectedCardsForSecondRow = [];
    selectedCardsFromThirdRow = [];

    // List<String> selectedCards = [];
    // List<String> selectedCardsForSecondRow = [];
    // List<String> selectedCardsFromThirdRow = [];
    // List<String> remainingDeckElements = [];
    // List<String> shuffleDeckElements = [];
    selectedCardToSwap = [];
    currentRound = 1;
    // noOfChips = 0;
    currentLevel = 1;
    playerScore = 0;
    aiScore = 0;
    notifyListeners();
  }
}
