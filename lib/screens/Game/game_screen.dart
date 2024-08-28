import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/utils/game.dart';
import 'package:joker_battle/provider/card_provider.dart';

class GameScreen extends StatefulWidget {
  static const String routeName = '/game';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => GameScreen(),
    );
  }

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _selectedButtonIndex = 0;
  List<String> selectedCardsList = [];
  int playerScore = 0;
  int aiScore = 0;

  int getCardPoints(String rank) {
    switch (rank) {
      case 'J':
        return 11;
      case 'Q':
        return 12;
      case 'K':
        return 13;
      case 'A':
        return 14;
      default:
        return int.tryParse(rank) ?? 0;
    }
  }

  bool isStraightHand(List<int> rankValues) {
    rankValues.sort();
    for (int i = 0; i < rankValues.length - 1; i++) {
      if (rankValues[i + 1] != rankValues[i] + 1) {
        return false;
      }
    }
    return true;
  }

  int calculateScore(List<String> combo) {
    int score = 0;
    Map<String, int> rankCounts = {};
    Map<String, int> suitCounts = {};
    List<int> rankValues = [];

    for (var card in combo) {
      String rank = card
          .split('_')[2]
          .substring(0, 1); // Assuming card format is "card_spades_A.png"
      String suit = card.split('_')[1];
      int points = getCardPoints(rank);
      score += points;
      rankValues.add(points);

      rankCounts[rank] = (rankCounts[rank] ?? 0) + 1;
      suitCounts[suit] = (suitCounts[suit] ?? 0) + 1;
    }

    bool isFlush = suitCounts.containsValue(5);
    bool isStraight = isStraightHand(rankValues);

    // Apply scoring based on hand type
    if (isFlush && isStraight) {
      score *= 7; // Straight Flush
    } else if (rankCounts.containsValue(4)) {
      score *= 5; // Four of a Kind
    } else if (rankCounts.containsValue(3) && rankCounts.containsValue(2)) {
      score *= 4; // Full House
    } else if (isFlush) {
      score *= 3; // Flush
    } else if (isStraight) {
      score *= 2; // Straight
    } else if (rankCounts.containsValue(3)) {
      score *= 2; // Three of a Kind
    } else if (rankCounts.values.where((v) => v == 2).length == 2) {
      score += 10; // Two Pair
    } else if (rankCounts.containsValue(2)) {
      score += 5; // One Pair
    } else {
      score *= 1; // High Card
    }

    return score;
  }

  void _calculateScores() {
    List<String> userSelectedCards =
        context.read<CardsProvider>().selectedCardsFromThirdRow;

    playerScore = calculateScore(userSelectedCards);

    List<String> aiSelectedCards =
        context.read<AICardsProvider>().selectedAICards;
    aiScore = calculateScore(aiSelectedCards);

    // Display the result
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Result"),
          content: Text("Your Score: $playerScore\nAI Score: $aiScore"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _onButtonPressed(int index) {
    setState(() {
      _selectedButtonIndex = index;
    });
  }

  void _addToSelectedCards(String index) {
    setState(() {
      selectedCardsList
          .add(index); // Assuming ThirdCardData has an 'id' property
    });
  }

  @override
  Widget build(BuildContext context) {
    var content;

    if (_selectedButtonIndex == 0) {
      content = "";
    } else if (_selectedButtonIndex == 1) {
      content = "";
    } else if (_selectedButtonIndex == 2) {
      content = "";
    } else {
      content = "null";
    }

    List<String> deck = generateDeck();

    List<String> AIDeck = generateDeckForAI();

    final List<String> cardData = [
      'card_back.png',
      'card_back.png',
      'card_back.png',
      'card_back.png',
      'card_back.png',
      'card_back.png',
      'card_back.png',
    ];
    final List<String> cardDataAI = [
      'card_back.png',
      'card_back.png',
      'card_back.png',
      'card_back.png',
      'card_back.png',
    ];

    final List<String> secondCardData = [
      'transparent.png',
      'transparent.png',
      'transparent.png',
      'transparent.png',
      'transparent.png'
    ];

    final List<String> ThirdCardData = [
      'card_spades_A.png',
      'card_spades_J.png',
      'card_spades_K.png',
      'card_spades_Q.png',
      'card_spades_A.png',
    ];

    Widget buildCard(BuildContext context, int index) {
      return Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/${cardData[index]}'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 207, 149),
        body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(6, 30),
                          backgroundColor: Color(0xFF838796),
                          foregroundColor: Colors.white,
                          // elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/backbutton.svg',
                          fit: BoxFit.cover,
                          // width: 49,
                        ),
                        // ),
                      ),

                      const SizedBox(width: 45),
                      ElevatedButton(
                        onPressed: () {
                          // Handle button 1 press
                          _onButtonPressed(0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedButtonIndex == 0
                              ? Color(0xFF9B9DAD)
                              : Color.fromARGB(255, 210, 220, 255),
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text('33',
                            style: TextStyle(
                                fontFamily: "BreatheFire",
                                fontSize: 25,
                                color: Colors.white)),
                      ),

                      const SizedBox(width: 27),
                      ElevatedButton(
                        onPressed: () {
                          _onButtonPressed(2);
                          // Navigator.pushNamed(context, '/');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(6, 30),
                          backgroundColor: Color(0xFF838796),
                          foregroundColor: Colors.white,
                          // elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/info.svg',
                          fit: BoxFit.cover,
                          // width: 49,
                        ),
                      ),
                      // const SizedBox(width: 15),
                    ]),
                const SizedBox(height: 45),
                Container(
                  height: 560,
                  // decoration: BoxDecoration(
                  //   // border: Border.all(
                  //   //   color: const Color.fromARGB(255, 224, 221, 221), // Border color
                  //   //   width: 0, // Border width
                  //   // ),
                  // ),
                  child: Stack(children: [
                    Positioned(
                      right: 145,
                      top: 0,
                      child: SvgPicture.asset(
                        'assets/images/kadoo-head.svg',
                        fit: BoxFit.cover,
                        width: 100,
                      ),
                    ),
                    Positioned(
                      bottom: 22,
                      right: 147, // Adjust top position as needed
                      // right: 30,
                      child: SvgPicture.asset(
                        'assets/images/kadoo-tail.svg',

                        // fit: BoxFit.cover,
                        // width: 49,
                      ),
                    ),

                    //orange_circle
                    Positioned(
                      top: 70,
                      right: -4,
                      child: Container(
                          // alignment: Alignment.center,
                          height: 390,
                          width: 390,
                          // padding: EdgeInsets.all(170),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: const AssetImage(
                                    'assets/images/texture.png'),
                                fit: BoxFit.fill),
                            border: Border.all(
                                color: const Color.fromARGB(255, 153, 0, 0),
                                width: 3.0),
                            // gradient: LinearGradient(
                            //   colors: [
                            //     Color(0xFFF39036),
                            //     Color(0xFFE7762A),
                            //     Color(0xFFDD6221)
                            //   ],
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            // ),

                            // color: Color(0xFFF39036),
                            // border: Border.all(
                            //   color: Color(0xFFF39036), // Set the border color
                            //   width: 4,
                            //   // Set the border width
                            // ),
                            borderRadius: BorderRadius.circular(200),
                            //   image: const DecorationImage(
                            //     image: AssetImage('assets/images/Vector.png'),
                            //     fit: BoxFit.fill,
                            //   ),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                SvgPicture.asset(
                                  'assets/images/AI.svg',
                                  fit: BoxFit.cover,
                                  width: 30,
                                ),

                                //first-card-row
                                Consumer<AICardsProvider>(
                                    builder: (context, counter, child) {
                                  return SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          counter.selectedAICards.length > 1
                                              ? counter.selectedAICards.length
                                              : cardDataAI.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 39,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                    '${counter.selectedAICards.length > 1 ? counter.selectedAICards[index] : "assets/images/${cardDataAI[index]}"}',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                }),

                                SizedBox(
                                  height: 18,
                                  child: ElevatedButton(
                                      child: Text("random",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 14)),
                                      onPressed: () {
                                        // Handle button 1 press
                                      },
                                      style: ElevatedButton.styleFrom(
                                          // elevation: 30,

                                          //                 horizontal: 5, vertical: 12),
                                          backgroundColor: Color(0xFF88E060),

                                          // padding: EdgeInsets.zero,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 23))),
                                ),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 10),
                                      child: SvgPicture.asset(
                                        'assets/images/threeRound.svg',
                                        fit: BoxFit.cover,
                                        width: 49,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),

                                    //second-card-row
                                    Consumer<CardsProvider>(
                                        builder: (context, counter, child) {
                                      return SizedBox(
                                        height: 70,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 5,
                                          // counter
                                          //             .selectedCardsFromThirdRow
                                          //             .length >
                                          //         0
                                          //     ? counter
                                          //         .selectedCardsFromThirdRow
                                          //         .length
                                          //     : secondCardData.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Row(
                                              children: [
                                                Container(
                                                  width: 28,
                                                  height: 39,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          '${index < counter.selectedCardsFromThirdRow.length ? counter.selectedCardsFromThirdRow[index] : "assets/images/${secondCardData[index]}"}'
                                                          // '${counter.selectedCardsFromThirdRow.length > 0 ? counter.selectedCardsFromThirdRow[index] : "assets/images/${secondCardData[index]}"}',
                                                          ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 9,
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),

                                SizedBox(
                                    height: 18,
                                    child: ElevatedButton(
                                        child: Text("random",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "BreatheFire",
                                                fontSize: 14)),
                                        onPressed: () {
                                          // Handle button 1 press
                                        },
                                        style: ElevatedButton.styleFrom(
                                            // elevation: 30,

                                            //                 horizontal: 5, vertical: 12),
                                            backgroundColor: Color(0xFF88E060),

                                            // padding: EdgeInsets.zero,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 23)))),

                                //third-row-cards
                                Consumer<CardsProvider>(
                                    builder: (context, counter, child) {
                                  return SizedBox(
                                    height: 50,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 7,
                                      // counter.selectedCards.length > 0
                                      //     ? counter.selectedCards.length
                                      //     : cardData.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // context.read<CardsProvider>().selectedCardsFromThirdRow(counter.selectedCards[index]);
                                                context
                                                    .read<CardsProvider>()
                                                    .selectCardFromThirdRow(
                                                        counter.selectedCards[
                                                            index]);
                                              },
                                              splashColor: const Color.fromARGB(
                                                  255, 7, 176, 255),
                                              highlightColor: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                width: 28,
                                                height: 39,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        //if index<

//  '${(index)>=counter.selectedCards.length ? "assets/images/${cardData[index]}" : counter.selectedCards[index] }'),
                                                        '${"${counter.shuffleDeckElements[index]}"}'),
                                                    // '${counter.selectedCards.length > 0 ? counter.selectedCards[index] : "assets/images/${cardData[index]}"}'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                }),
                                SvgPicture.asset(
                                  'assets/images/you.svg',
                                  fit: BoxFit.cover,
                                  width: 45,
                                ),
                                const SizedBox(
                                  height: 7,
                                )
                              ])),
                    ),
                  ]),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(3, 15, 7, 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFECE3CE),
                    border: Border.all(
                      color: Color(0xFFD3BF8F), // Set the border color
                      width: 4,
                      // Set the border width
                    ),
                    borderRadius: BorderRadius.circular(20),
                    // image: const DecorationImage(
                    //   image: AssetImage('assets/images/Vector.png'),
                    //   fit: BoxFit.fill,
                    // ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            image: const DecorationImage(
                                image: const AssetImage(
                                    'assets/images/button_border.png'),
                                fit: BoxFit.fill)),
                        child: Consumer<CardsProvider>(
                            builder: (context, counter, child) {
                          return ElevatedButton(
                              onPressed: () {
                                context
                                    .read<AICardsProvider>()
                                    .selectAICards(shuffleAIDeck(AIDeck));

                                _calculateScores();
                                // context
                                //     .read<CardsProvider>()
                                //     .selectCardsForSecondRow(
                                //         counter.selectedCards);

                                // Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(6, 30),
                                backgroundColor: const Color(0xFFD3BF8F),
                                foregroundColor: Colors.white,
                                // elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                              ),
                              child: const Text("Play",
                                  style: TextStyle(
                                      fontFamily: "BreatheFire",
                                      fontSize: 20,
                                      color:
                                          Color.fromARGB(255, 228, 231, 239)))
                              // ),
                              );
                        }),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            image: const DecorationImage(
                                image: const AssetImage(
                                    'assets/images/button_border.png'),
                                fit: BoxFit.fill)),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(6, 30),
                            backgroundColor: Color(0xFFD3BF8F),
                            foregroundColor: Colors.white,
                            // elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12.2),
                          ),
                          child: const Text("Joker",
                              style: TextStyle(
                                  fontFamily: "BreatheFire",
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 222, 225, 237))),
                          // ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            image: const DecorationImage(
                                image: const AssetImage(
                                    'assets/images/button_border.png'),
                                fit: BoxFit.fill)),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AICardsProvider>().removeCards();
                            context.read<CardsProvider>().removeCards();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(6, 30),
                            backgroundColor: Color(0xFFD3BF8F),
                            foregroundColor: Colors.white,
                            // elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 14.5),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/rewind.svg',
                            fit: BoxFit.cover,
                            // width: 49,
                          ),
                          // ),
                        ),
                      ),

                      //cards-grid
                      Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              Provider.of<CardsProvider>(context, listen: false)
                                  .remainingDeck(deck);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        height: 400,
                                        child: Consumer<CardsProvider>(
                                            builder: (context, counter, child) {
                                          return Container(
                                              alignment: Alignment.center,
                                              child: GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 4,
                                                  mainAxisSpacing: 1,
                                                  crossAxisSpacing: 1,
                                                ),
                                                itemCount: counter
                                                    .remainingDeckElements
                                                    .length,
                                                // shuffleDeck(deck).length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return SelectableCard(
                                                      imageUrl: counter
                                                              .remainingDeckElements[
                                                          index],

                                                      //  shuffleDeck(
                                                      //     deck)[index],
                                                      // ThirdCardData[index]

                                                      title: "");
                                                },
                                              ));
                                        }),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ),
                                    image: const DecorationImage(
                                        image: const AssetImage(
                                            'assets/images/card_hearts_10.png'),
                                        fit: BoxFit.fill)),
                                child: Text(""),
                                width: 45,
                                height: 50),
                          ),
                          Consumer<CardsProvider>(
                              builder: (context, counter, child) {
                            return Text("${counter.selectedCards.length}/52");
                          })
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ))

        // )

        );
  }
}

class SelectableCard extends StatefulWidget {
  final String imageUrl;
  final String title;

  const SelectableCard({
    required this.imageUrl,
    required this.title,
  });

  @override
  _SelectableCardState createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: _isSelected
            ? BorderSide(color: Color.fromARGB(255, 2, 178, 34), width: 5)
            : BorderSide.none,
      ),
      child: Consumer<CardsProvider>(
        builder: (context, counter, child) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _isSelected = !_isSelected;

                // if (counter.selectedCards.length <= 5)
                // _isSelected = !_isSelected;

                if (_isSelected == false) {
                  context
                      .read<CardsProvider>()
                      .removeSingleCard(widget.imageUrl);
                } else {
                  context.read<CardsProvider>().selectCards(widget.imageUrl);
                }
              });
            },
            child: Column(
              children: [
                Image.asset("${widget.imageUrl}"),
                // Text(widget.title),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class CardsProvider with ChangeNotifier {
//   List<String> selectedCards = [];
//   List<String> selectedCardsForSecondRow = [];
//   List<String> selectedCardsFromThirdRow = [];
//   List<String> remainingDeckElements = [];
//   List<String> shuffleDeckElements = [];

//   void remainingDeck(deck) {
//     remainingDeckElements =
//         deck.where((element) => !selectedCards.contains(element)).toList();
//     print({"murgha": remainingDeckElements.length});
//     notifyListeners();
//   }

//   void shuffleDeckElement(deck) {
//     shuffleDeckElements = shuffleDeck(deck);
//     selectedCards = [];

//     print({"murgha": shuffleDeckElements.length});
//     notifyListeners();
//   }

//   // List<String> get selectedCards;

//   void selectCards(String path) {
//     if ((selectedCards.length < 7) && !selectedCards.contains(path)) {
//       selectedCards.add(path);
//     }
//     notifyListeners();
//   }

//   void selectCardsForSecondRow(List<String> selectedCards) {
//     // if (selectedCards.length <= 4 && !selectedCards.contains(path)) {
//     //   selectedCards.add(path);
//     // }
//     selectedCardsForSecondRow = selectedCards;
//     notifyListeners();
//   }

//   void selectCardFromThirdRow(String path) {
//     if (selectedCardsFromThirdRow.length <= 4 &&
//         !selectedCardsFromThirdRow.contains(path)) {
//       selectedCardsFromThirdRow.add(path);
//     }
//     notifyListeners();
//   }

//   void removeSingleCard(String path) {
//     selectedCards.remove(path);
//     selectedCardsForSecondRow.remove(path);
//     notifyListeners();
//   }

//   void removeCards() {
//     selectedCards = [];
//     selectedCardsForSecondRow = [];
//     selectedCardsFromThirdRow = [];
//     notifyListeners();
//   }
// }

class AICardsProvider with ChangeNotifier {
  List<String> selectedAICards = [];

  // List<String> get selectedCards;

  void selectAICards(List<String> AICards) {
    selectedAICards = AICards;
    notifyListeners();
  }

  void removeCards() {
    selectedAICards = [];
    notifyListeners();
  }
}
