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
  bool? winStatus;
  int currentRound = 1;

  void remainingDeck(deck) {
    remainingDeckElements =
        deck.where((element) => !selectedCards.contains(element)).toList();
    print({"murgha": remainingDeckElements.length});
    notifyListeners();
  }

  void incrementCurrentRound() {
    if (currentRound < 6) {
      currentRound++;
    }
    // print({"murgha": remainingDeckElements.length});
    notifyListeners();
  }

  void setCurrentRound(int value) {
    currentRound = value;
    if (value == 0) {
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
    selectedCards = [];
    selectedCardsForSecondRow = [];
    selectedCardsFromThirdRow = [];
    notifyListeners();
  }
}
