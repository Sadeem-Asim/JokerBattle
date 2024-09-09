import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/provider/card_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _selectedButtonIndex = 0;
  List<String> selectedCardsList = [];
  int playerScore = 0;
  int aiScore = 0;
  final player = AudioPlayer();
  bool showWhiteText = false;
  bool isPlay = false;
  late AnimationController _controller;
  late Animation _animation;
  AnimationStatus _status = AnimationStatus.dismissed;
  void initState() {
    super.initState();
    openBox();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(end: 1.0, begin: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _status = status;
      });
  }

  void openBox() async {
    var box = await Hive.openBox("myBox");
    var b = Hive.box("myBox");
    // print(b.get("noOfChips"));
    context.read<CardsProvider>().updateChipsInProvider(b.get("noOfChips"),
        b.get("level"), b.get("purchaseJokers"), b.get("purchaseCards"));
  }

  List<Map<String, dynamic>> combos = [];
  List<Map<String, dynamic>> combosAi = [];

  int getCardPoints(String rank) {
    switch (rank) {
      case 'J.':
        return 11;
      case 'Q.':
        return 12;
      case 'K.':
        return 13;
      case 'A.':
        return 14;
      case '01':
        return 1;
      case '02':
        return 2;
      case '03':
        return 3;
      case '04':
        return 4;
      case '05':
        return 5;
      case '06':
        return 6;
      case '07':
        return 7;
      case '08':
        return 8;
      case '09':
        return 9;
      case '10':
        return 10;
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
    int baseScore = 0;
    Map<String, int> rankCounts = {};
    Map<String, int> suitCounts = {};
    List<int> rankValues = [];
    Map<String, int> cardPoints = {};
    for (var card in combo) {
      String rank = card.split('_')[2].substring(0, 2);
      String suit = card.split('_')[1];
      int points = getCardPoints(rank);
      points = context.read<CardsProvider>().score ? points * 2 : points;
      rankValues.add(points);
      rankCounts[rank] = (rankCounts[rank] ?? 0) + 1;
      suitCounts[suit] = (suitCounts[suit] ?? 0) + 1;
      cardPoints[rank] = points;
    }
    bool isFlush = suitCounts.containsValue(5);
    bool isStraight = isStraightHand(rankValues);

    int combinationScore = 0;

    // Apply scoring based on hand type
    if (isFlush && isStraight) {
      for (var points in rankValues) {
        baseScore += points; // Add points of all cards for Straight Flush
      }
      combinationScore = baseScore * 7;
      combos.add({
        "Base Score": baseScore,
        "Straight Flush : ": combinationScore,
      });
    } else if (rankCounts.containsValue(4)) {
      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 4) {
          baseScore += cardPoints[rank]! * 4; // Add points for Four of a Kind
        }
      }
      combinationScore = baseScore * 5;
      combos.add({
        "Base Score": baseScore,
        "Four of a Kind": combinationScore,
      });
    } else if (rankCounts.containsValue(3) && rankCounts.containsValue(2)) {
      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 3) {
          baseScore += cardPoints[rank]! * 3;
        } else if (rankCounts[rank] == 2) {
          baseScore += cardPoints[rank]! * 2;
        }
      }
      combinationScore = baseScore * 4;

      combos.add({
        "Base Score": baseScore,
        "Full House": combinationScore,
      });
    } else if (isFlush) {
      for (var points in rankValues) {
        baseScore += points; // Add points of all cards for Flush
      }
      combinationScore = baseScore * 3;
      combos.add({
        "Base Score": baseScore,
        "Flush": combinationScore,
      });
    } else if (isStraight) {
      for (var points in rankValues) {
        baseScore += points; // Add points of all cards for Straight
      }
      combinationScore = baseScore * 2;

      combos.add({
        "Base Score": baseScore,
        "Straight": combinationScore,
      });
    } else if (rankCounts.values.where((v) => v == 2).length == 2) {
      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 2 && cardPoints[rank] != null) {
          baseScore += cardPoints[rank]! * 2; // Add points of both pairs
        }
      }
      combinationScore = 10;
      combos.add({
        "Base Score": baseScore,
        "Two Pair Bonus": combinationScore,
      });
    } else if (rankCounts.containsValue(2)) {
      // One Pair

      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 2 && cardPoints[rank] != null) {
          baseScore += cardPoints[rank]! * 2; // Add points of the pair
          break;
        }
      }
      combinationScore = 5;
      combos.add({
        "Base Score": baseScore,
        "One Pair Bonus": combinationScore,
      });
    } else {
      baseScore = rankValues.reduce((a, b) => a > b ? a : b);
      combinationScore = baseScore;
      combos.add({
        "Base Score": baseScore,
        "High Card Bonus": combinationScore,
      });
    }
    int total = baseScore + combinationScore;
    if (context.read<CardsProvider>().handBonus) {
      int handBonus = 0;
      List<String> cards = context
          .read<CardsProvider>()
          .selectedCards
          .where((card) => !context
              .read<CardsProvider>()
              .selectedCardsFromThirdRow
              .contains(card))
          .toList();
      for (var card in cards) {
        String rank = card.split('_')[2].substring(0, 2);
        int points = getCardPoints(rank);
        handBonus += points;
      }
      combos.add({"Hand Bonus": handBonus});
      total += handBonus;
    }

    if (context.read<CardsProvider>().score) {
      combos.add({"Score Joker Bonus Applied": 0});
    }
    if (context.read<CardsProvider>().emptyBonus) {
      int emptyBonus = 0;
      List<String> cards =
          context.read<CardsProvider>().selectedCardsFromThirdRow.toList();
      for (var card in cards) {
        String rank = card.split('_')[2].substring(0, 2);
        int points = getCardPoints(rank);
        emptyBonus += points;
      }
      combos.add({"Empty Bonus": emptyBonus});
      total += emptyBonus;
    }

    combos.add({"Total": total});
    return total;
  }

  int calculateScoreAi(List<String> combo) {
    int baseScore = 0;

    Map<String, int> rankCounts = {};
    Map<String, int> suitCounts = {};
    List<int> rankValues = [];

    Map<String, int> cardPoints = {};

    for (var card in combo) {
      String rank = card.split('_')[2].substring(0, 2);
      String suit = card.split('_')[1];
      int points = getCardPoints(rank);

      baseScore += points;
      rankValues.add(points);

      rankCounts[rank] = (rankCounts[rank] ?? 0) + 1;
      suitCounts[suit] = (suitCounts[suit] ?? 0) + 1;

      // Keep track of points for each rank
      cardPoints[rank] = points;
    }

    bool isFlush = suitCounts.containsValue(5);
    bool isStraight = isStraightHand(rankValues);

    int combinationScore = 0;

    // Apply scoring based on hand type
    if (isFlush && isStraight) {
      for (var points in rankValues) {
        baseScore += points; // Add points of all cards for Straight Flush
      }
      combinationScore = baseScore * 7;
      combosAi.add({
        "Opponent Base Score": baseScore,
        "Straight Flush : ": combinationScore,
        "Total": baseScore + combinationScore
      });
    } else if (rankCounts.containsValue(4)) {
      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 4) {
          baseScore += cardPoints[rank]! * 4; // Add points for Four of a Kind
        }
      }
      combinationScore = baseScore * 5;
      combosAi.add({
        "Opponent Base Score": baseScore,
        "Four of a Kind": combinationScore,
        "Total": baseScore + combinationScore
      });
    } else if (rankCounts.containsValue(3) && rankCounts.containsValue(2)) {
      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 3) {
          baseScore += cardPoints[rank]! * 3;
        } else if (rankCounts[rank] == 2) {
          baseScore += cardPoints[rank]! * 2;
        }
      }
      combinationScore = baseScore * 4;

      combosAi.add({
        "Opponent Base Score": baseScore,
        "Full House": combinationScore,
        "Total": baseScore + combinationScore
      });
    } else if (isFlush) {
      for (var points in rankValues) {
        baseScore += points; // Add points of all cards for Flush
      }
      combinationScore = baseScore * 3;
      combosAi.add({
        "Opponent Base Score": baseScore,
        "Flush": combinationScore,
        "Total": baseScore + combinationScore,
      });
    } else if (isStraight) {
      for (var points in rankValues) {
        baseScore += points; // Add points of all cards for Straight
      }
      combinationScore = baseScore * 2;

      combosAi.add({
        "Opponent Base Score": baseScore,
        "Straight": combinationScore,
        "Total": baseScore + combinationScore,
      });
    } else if (rankCounts.values.where((v) => v == 2).length == 2) {
      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 2 && cardPoints[rank] != null) {
          baseScore += cardPoints[rank]! * 2; // Add points of both pairs
        }
      }
      combinationScore = 10;
      combosAi.add({
        "Opponent Base Score": baseScore,
        "Two Pair Bonus": combinationScore,
        "Total": baseScore + combinationScore,
      });
    } else if (rankCounts.containsValue(2)) {
      // One Pair

      for (var rank in rankCounts.keys) {
        if (rankCounts[rank] == 2 && cardPoints[rank] != null) {
          baseScore += cardPoints[rank]! * 2; // Add points of the pair
          break;
        }
      }
      combinationScore = 5;
      combosAi.add({
        "Opponent Base Score": baseScore,
        "One Pair Bonus": combinationScore,
        "Total": baseScore + combinationScore
      });
    } else {
      baseScore = rankValues.reduce((a, b) => a > b ? a : b);
      combinationScore = baseScore;
      combosAi.add({
        "Opponent Base Score": baseScore,
        "High Card Bonus": combinationScore,
        "Total": baseScore + combinationScore
      });
    }

    return combinationScore + baseScore;
  }

  List<String> generateSuits(String path) {
    List<String> deck = generateDeck();
    String suit = path.split('_')[2].substring(0, 2);
    List<String> suits = deck.where((card) => card.contains(suit)).toList();
    suits.removeWhere((card) => card == path);
    return suits;
  }

  void calculateScores() {
    List<String> userSelectedCards =
        context.read<CardsProvider>().selectedCardsFromThirdRow;

    playerScore = calculateScore(userSelectedCards);

    context.read<CardsProvider>().setPlayerScore(
        (context.read<CardsProvider>().playerScore) + playerScore);

    List<String> aiSelectedCards =
        context.read<CardsProvider>().selectedCardsForAi;
    aiScore = calculateScoreAi(aiSelectedCards);

    context
        .read<CardsProvider>()
        .setAiScore((context.read<CardsProvider>().aiScore) + aiScore);
    setState(() {
      aiScore = aiScore;
      playerScore = playerScore;
    });
  }

  Future _calculateScores() async {
    bool winStatus = playerScore > aiScore ? true : true;
    if (Provider.of<CardsProvider>(context, listen: false).currentRound == 6) {
      winStatus = playerScore > aiScore ? true : false;
    }

    if (winStatus == true) {
      Future.delayed(
          const Duration(seconds: 0, milliseconds: 0),
          () => {
                if (winStatus == true &&
                    Provider.of<CardsProvider>(context, listen: false)
                            .currentRound ==
                        6)
                  {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return PopScope(
                            canPop: false,
                            child: Scaffold(
                              backgroundColor: Colors.black.withOpacity(0.8),
                              body: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: const AssetImage(
                                          'assets/images/background.png'),
                                      fit: BoxFit.fill,
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.8),
                                          BlendMode.darken)),
                                ),
                                // alignment: Alignment.center,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(children: [
                                        const SizedBox(width: 120),
                                        Column(
                                          children: [
                                            const Text(
                                              "AI",
                                              style: TextStyle(
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 30,
                                                  color: Color(0xFFF7A74F)),
                                            ),
                                            SizedBox(
                                              height: 18,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    // Handle button 1 press
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          // elevation: 30,

                                                          //                 horizontal: 5, vertical: 12),
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFF88E060),

                                                          // padding: EdgeInsets.zero,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 0,
                                                                  horizontal:
                                                                      23)),
                                                  child: Text(
                                                      "${context.read<CardsProvider>().aiScore}",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              "BreatheFire",
                                                          fontSize: 14))),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Column(
                                          children: [
                                            const Text(
                                              "You",
                                              style: TextStyle(
                                                  fontFamily: "BreatheFire",
                                                  color: Color(0xFFF7A74F),
                                                  fontSize: 32),
                                            ),
                                            SizedBox(
                                              height: 18,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    // Handle button 1 press
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFF88E060),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 0,
                                                                  horizontal:
                                                                      23)),
                                                  child: Text(
                                                      "${context.read<CardsProvider>().playerScore}",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              "BreatheFire",
                                                          fontSize: 14))),
                                            ),
                                          ],
                                        )
                                      ]),
                                      const SizedBox(height: 7),
                                      const Text(
                                        "You Win!",
                                        style: TextStyle(
                                            fontFamily: "BreatheFire",
                                            fontSize: 40,
                                            color: Color(0xFFF7A74F)),
                                      ),

                                      //upgrade button
                                      ElevatedButton(
                                          onPressed: () async {
                                            var box =
                                                await Hive.openBox("myBox");
                                            var b = Hive.box("myBox");

                                            await player.play(AssetSource(
                                                'Music/Upgrade.mp3'));
                                            context
                                                .read<CardsProvider>()
                                                .addTenChipsOnWin();
                                            b.put(
                                                "noOfChips",
                                                context
                                                    .read<CardsProvider>()
                                                    .noOfChips);
                                            b.put(
                                                "level",
                                                context
                                                    .read<CardsProvider>()
                                                    .currentLevel);
                                            b.put(
                                                "purchaseJokers",
                                                context
                                                    .read<CardsProvider>()
                                                    .purchaseJokers);
                                            b.put(
                                                "purchaseCards",
                                                context
                                                    .read<CardsProvider>()
                                                    .purchaseCards);

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          // ElevatedButton(
                                                          //   onPressed: () {
                                                          //     Navigator.pop(
                                                          //         context);
                                                          //   },
                                                          //   style:
                                                          //       ElevatedButton
                                                          //           .styleFrom(
                                                          //     minimumSize:
                                                          //         const Size(
                                                          //             6, 30),
                                                          //     backgroundColor:
                                                          //         const Color(
                                                          //             0xFF838796),
                                                          //     foregroundColor:
                                                          //         Colors.white,
                                                          //     // elevation: 10,
                                                          //     shape:
                                                          //         RoundedRectangleBorder(
                                                          //       borderRadius:
                                                          //           BorderRadius
                                                          //               .circular(
                                                          //                   2),
                                                          //     ),
                                                          //     padding:
                                                          //         const EdgeInsets
                                                          //             .symmetric(
                                                          //             horizontal:
                                                          //                 8,
                                                          //             vertical:
                                                          //                 8),
                                                          //   ),
                                                          //   child: SvgPicture
                                                          //       .asset(
                                                          //     'assets/images/backbutton.svg',
                                                          //     fit: BoxFit.cover,
                                                          //     // width: 49,
                                                          //   ),
                                                          //   // ),
                                                          // ),
                                                          const SizedBox(
                                                              width: 45),
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                // Handle button 1 press
                                                                _onButtonPressed(
                                                                    0);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor: _selectedButtonIndex ==
                                                                        0
                                                                    ? const Color(
                                                                        0xFF9B9DAD)
                                                                    : const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        210,
                                                                        220,
                                                                        255),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                elevation: 10,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                              ),
                                                              child: Consumer<
                                                                      CardsProvider>(
                                                                  builder: (context,
                                                                      counter,
                                                                      child) {
                                                                return Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      'assets/images/upgrade-card-2.svg',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      // width: 49,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            7),
                                                                    Text(
                                                                        '${counter.noOfChips}',
                                                                        style: const TextStyle(
                                                                            fontFamily:
                                                                                "BreatheFire",
                                                                            fontSize:
                                                                                25,
                                                                            color:
                                                                                Colors.white)),
                                                                  ],
                                                                );
                                                              })),
                                                          const SizedBox(
                                                              width: 27),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              _onButtonPressed(
                                                                  2);
                                                              // Navigator.pushNamed(context, '/');
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              minimumSize:
                                                                  const Size(
                                                                      6, 30),
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xFF838796),
                                                              foregroundColor:
                                                                  Colors.white,
                                                              // elevation: 10,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            2),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          8),
                                                            ),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/images/info.svg',
                                                              fit: BoxFit.cover,
                                                              // width: 49,
                                                            ),
                                                          ),
                                                        ]),
                                                    const SizedBox(height: 45),
                                                    //upgrade-grid
                                                    SizedBox(
                                                      height: 500,
                                                      child: Consumer<
                                                              CardsProvider>(
                                                          builder: (context,
                                                              counter, child) {
                                                        return Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: GridView
                                                                .builder(
                                                              gridDelegate:
                                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    4,
                                                                mainAxisSpacing:
                                                                    1,
                                                                crossAxisSpacing:
                                                                    1,
                                                              ),
                                                              itemCount: counter
                                                                  .upgradeScreenDeck
                                                                  .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return SelectableCardForUpgrade(
                                                                    imageUrl: counter
                                                                        .upgradeScreenDeck[
                                                                            index]
                                                                        .imageUrl,
                                                                    cost: counter
                                                                        .upgradeScreenDeck[
                                                                            index]
                                                                        .cost,
                                                                    isPurchased: counter
                                                                        .upgradeScreenDeck[
                                                                            index]
                                                                        .isPurchased);
                                                              },
                                                            ));
                                                      }),
                                                    ),

                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        context
                                                            .read<
                                                                CardsProvider>()
                                                            .incrementCurrentLevel();
                                                        context
                                                            .read<
                                                                CardsProvider>()
                                                            .removeCards();

                                                        await player.play(
                                                            AssetSource(
                                                                'Music/Round-start.mp3'));
                                                        Navigator.pushNamed(
                                                            context, '/game');
                                                        b.put(
                                                            "noOfChips",
                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .noOfChips);
                                                        b.put(
                                                            "level",
                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .currentLevel);
                                                        b.put(
                                                            "purchaseJokers",
                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .purchaseJokers);
                                                        b.put(
                                                            "purchaseCards",
                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .purchaseCards);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF838796),
                                                        foregroundColor:
                                                            Colors.white,
                                                        elevation: 10,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 85,
                                                                vertical: 2),
                                                      ),
                                                      child: const Text(
                                                        'NEXT LEVEL',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "BreatheFire",
                                                            fontSize: 25),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 30,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),

                                              //                 horizontal: 5, vertical: 12),
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 168, 168, 168),

                                              // padding: EdgeInsets.zero,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 80)),
                                          child: const Text("Upgrade",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 35))),
                                      // ),
                                    ]),
                              ),
                            ),
                          );

                          // );
                        })
                  }
              });
      return true;
    } else {
      player.play(AssetSource('Music/Round-over.mp3'));
      Future.delayed(
          const Duration(seconds: 0, milliseconds: 70),
          () => {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PopScope(
                        canPop: false,
                        child: Scaffold(
                          backgroundColor: Colors.black.withOpacity(0.8),
                          body: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: const AssetImage(
                                      'assets/images/background.png'),
                                  fit: BoxFit.fill,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.8),
                                      BlendMode.darken)),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(children: [
                                    const SizedBox(width: 120),
                                    Column(
                                      children: [
                                        const Text(
                                          "AI",
                                          style: TextStyle(
                                              fontFamily: "BreatheFire",
                                              fontSize: 30,
                                              color: Color(0xFFF7A74F)),
                                        ),
                                        SizedBox(
                                          height: 18,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                // Handle button 1 press
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  // elevation: 30,

                                                  //                 horizontal: 5, vertical: 12),
                                                  backgroundColor:
                                                      const Color(0xFF88E060),

                                                  // padding: EdgeInsets.zero,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 0,
                                                      horizontal: 23)),
                                              child: Text("$aiScore",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "BreatheFire",
                                                      fontSize: 14))),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          "You",
                                          style: TextStyle(
                                              fontFamily: "BreatheFire",
                                              color: Color(0xFFF7A74F),
                                              fontSize: 32),
                                        ),
                                        SizedBox(
                                          height: 18,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                // Handle button 1 press
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  // elevation: 30,

                                                  //                 horizontal: 5, vertical: 12),
                                                  backgroundColor:
                                                      const Color(0xFF88E060),

                                                  // padding: EdgeInsets.zero,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 0,
                                                      horizontal: 23)),
                                              child: Text("$playerScore",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "BreatheFire",
                                                      fontSize: 14))),
                                        ),
                                      ],
                                    )
                                  ]),
                                  const SizedBox(height: 7),
                                  const Text(
                                    "You Lose",
                                    style: TextStyle(
                                        fontFamily: "BreatheFire",
                                        fontSize: 40,
                                        color: Color(0xFFF7A74F)),
                                  ),

                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/home');
                                        // Handle button 1 press
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 30,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),

                                          //                 horizontal: 5, vertical: 12),
                                          backgroundColor: const Color.fromARGB(
                                              255, 168, 168, 168),

                                          // padding: EdgeInsets.zero,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 80)),
                                      child: const Text("MENU",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 30))),
                                  // ),
                                ]),
                          ),
                        ),
                      );
                    })
              });

      return false;
    }
  }

  //local state methods
  void _onButtonPressed(int index) {
    setState(() {
      _selectedButtonIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 10),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(6, 30),
                          backgroundColor: const Color(0xFF838796),
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
                              ? const Color(0xFF9B9DAD)
                              : const Color.fromARGB(255, 210, 220, 255),
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                            '${context.read<CardsProvider>().currentLevel}',
                            style: const TextStyle(
                                fontFamily: "BreatheFire",
                                fontSize: 25,
                                color: Colors.white)),
                      ),
                      const SizedBox(width: 27),
                      ElevatedButton(
                        onPressed: () {
                          // _onButtonPressed(2);
                          Navigator.pushNamed(context, '/info');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(6, 30),
                          backgroundColor: const Color(0xFF838796),
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
                      const SizedBox(width: 13),
                    ]),
                SizedBox(height: MediaQuery.of(context).size.height * .04),
                Container(
                  height: MediaQuery.of(context).size.height * .70,
                  child: Stack(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        showWhiteText
                            ? Row(
                                children: [
                                  Column(
                                    children: [
                                      TweenAnimationBuilder(
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          duration: const Duration(seconds: 1),
                                          builder: (BuildContext context,
                                              double value, Widget? child) {
                                            return Text(
                                                "You Base Score:${combos[0]["Base Score"]}",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(value),
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 14,
                                                ));
                                          }),
                                      TweenAnimationBuilder(
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          duration: const Duration(seconds: 2),
                                          builder: (BuildContext context,
                                              double value, Widget? child) {
                                            return Text(
                                                "${combos[0].entries.map((entry) => entry.key).toList()[1]}:${combos[0][combos[0].entries.map((entry) => entry.key).toList()[1]]}",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(value),
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 13,
                                                ));
                                          }),
                                      TweenAnimationBuilder(
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          duration: const Duration(seconds: 3),
                                          builder: (BuildContext context,
                                              double value, Widget? child) {
                                            return Text(
                                                "Total:${combos[combos.length - 1][combos[combos.length - 1].entries.map((entry) => entry.key).toList()[0]]}",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(value),
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 13,
                                                ));
                                          }),
                                      TweenAnimationBuilder(
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          duration: const Duration(seconds: 3),
                                          builder: (BuildContext context,
                                              double value, Widget? child) {
                                            return Text(
                                                "Total:${combos[combos.length - 1][combos[combos.length - 1].entries.map((entry) => entry.key).toList()[0]]}",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(value),
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 13,
                                                ));
                                          }),
                                    ],
                                  ),
                                ],
                              )
                            : const Text(""),
                        Column(
                          children: [
                            Positioned(
                              right: 145,
                              top: 0,
                              child: SvgPicture.asset(
                                'assets/images/kadoo-head.svg',
                                fit: BoxFit.cover,
                                width: 100,
                              ),
                            ),
                          ],
                        ),
                        showWhiteText
                            ? Column(
                                children: [
                                  TweenAnimationBuilder(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(seconds: 1),
                                      builder: (BuildContext context,
                                          double value, Widget? child) {
                                        return Text(
                                            "Opponent Base Score:${combosAi[0]["Opponent Base Score"]}",
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(value),
                                              fontFamily: "BreatheFire",
                                              fontSize: 13,
                                            ));
                                      }),
                                  TweenAnimationBuilder(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(seconds: 2),
                                      builder: (BuildContext context,
                                          double value, Widget? child) {
                                        return Text(
                                            "${combosAi[0].entries.map((entry) => entry.key).toList()[1]}:${combosAi[0][combosAi[0].entries.map((entry) => entry.key).toList()[1]]}",
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(value),
                                              fontFamily: "BreatheFire",
                                              fontSize: 13,
                                            ));
                                      }),
                                  TweenAnimationBuilder(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(seconds: 3),
                                      builder: (BuildContext context,
                                          double value, Widget? child) {
                                        return Text(
                                            "Total:${combosAi[0][combosAi[0].entries.map((entry) => entry.key).toList()[2]]}",
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(value),
                                              fontFamily: "BreatheFire",
                                              fontSize: 13,
                                            ));
                                      }),
                                ],
                              )
                            : const Text(""),
                      ],
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.027,
                      right: MediaQuery.of(context).size.width * 0.38,
                      child: SvgPicture.asset(
                        'assets/images/kadoo-tail.svg',
                      ),
                    ),

                    //orange_circle
                    Positioned(
                      top: 70,
                      right: -4,
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.467,
                          width: MediaQuery.of(context).size.width * 0.99,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: const AssetImage(
                                    'assets/images/texture.png'),
                                fit: BoxFit.cover),
                            border: Border.all(
                                color: const Color.fromARGB(255, 153, 0, 0),
                                width: 3.0),
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                SvgPicture.asset(
                                  'assets/images/AI.svg',
                                  fit: BoxFit.cover,
                                  width: 30,
                                ),

                                //first-card-row
                                Consumer<CardsProvider>(
                                    builder: (context, counter, child) {
                                  return SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 5,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Row(
                                          children: [
                                            Transform(
                                              alignment:
                                                  FractionalOffset.center,
                                              transform: Matrix4.identity()
                                                ..setEntry(3, 2, 0.0015)
                                                ..rotateY(
                                                    3.14 * _animation.value),
                                              child: counter.visor
                                                  ? Container(
                                                      width: 28,
                                                      height: 39,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            counter.selectedCardsForAi[
                                                                index],
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )
                                                  : _animation.value <= 0.5
                                                      ? Transform(
                                                          alignment:
                                                              FractionalOffset
                                                                  .center,
                                                          transform: Matrix4
                                                              .identity()
                                                            ..rotateY(
                                                                0), // Front side
                                                          child: Container(
                                                            width: 28,
                                                            height: 39,
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    AssetImage(
                                                                  "assets/images/${cardDataAI[index]}",
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Transform(
                                                          alignment:
                                                              FractionalOffset
                                                                  .center,
                                                          transform: Matrix4
                                                              .identity()
                                                            ..rotateY(
                                                                3.14), // Back side
                                                          child: Container(
                                                            width: 28,
                                                            height: 39,
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    AssetImage(
                                                                  counter.selectedCardsForAi
                                                                              .length ==
                                                                          5
                                                                      ? counter
                                                                              .selectedCardsForAi[
                                                                          index]
                                                                      : "assets/images/${cardDataAI[index]}",
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
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
                                      onPressed: () {
                                        // Handle button 1 press
                                      },
                                      style: ElevatedButton.styleFrom(
                                          // elevation: 30,

                                          //                 horizontal: 5, vertical: 12),
                                          backgroundColor:
                                              const Color(0xFF88E060),

                                          // padding: EdgeInsets.zero,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 23)),
                                      child: Text(
                                          "${context.read<CardsProvider>().aiScore}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 14))),
                                ),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Consumer<CardsProvider>(
                                        builder: (context, counter, child) {
                                      return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 10),
                                          child: Text(
                                              "  ${counter.currentRound}\nRound",
                                              style: const TextStyle(
                                                  color: Color(0xFFF7A74F),
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 23)));
                                    }),
                                    const SizedBox(
                                      width: 10,
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
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Row(
                                              children: [
                                                Container(
                                                  width: 28,
                                                  height: 39,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(counter
                                                                      .selectedCardsFromThirdRow
                                                                      .length ==
                                                                  5 &&
                                                              isPlay == true
                                                          ? counter
                                                                  .selectedCardsFromThirdRow[
                                                              index]
                                                          : "assets/images/${secondCardData[index]}"),
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
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF88E060),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 23)),
                                        child: Text(
                                            "${context.read<CardsProvider>().playerScore}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: "BreatheFire",
                                                fontSize: 14)))),

                                //third-row-cards
                                Consumer<CardsProvider>(
                                    builder: (context, counter, child) {
                                  return SizedBox(
                                    height: 50,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: counter.selectedCards.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                final selectedCard = counter
                                                    .selectedCards[index];
                                                final cardsProvider = context
                                                    .read<CardsProvider>();

                                                if (cardsProvider
                                                    .isCardSelected(
                                                        selectedCard)) {
                                                  cardsProvider.unselectCard(
                                                      selectedCard);
                                                } else {
                                                  cardsProvider
                                                      .selectCardFromThirdRow(
                                                          selectedCard);
                                                }
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
                                                  border: counter
                                                          .selectedCardsFromThirdRow
                                                          .contains(counter
                                                                  .selectedCards[
                                                              index])
                                                      ? Border.all(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              253, 187, 54),
                                                          width: 3,
                                                        )
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  image: DecorationImage(
                                                    image: AssetImage(counter
                                                        .selectedCards[index]),
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
                  // padding: EdgeInsets.fromLTRB(3, 15, 7, 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE3CE),
                    border: Border.all(
                      color: const Color(0xFFD3BF8F), // Set the border color
                      width: 0,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SizedBox(
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
                          final bool isButtonEnabled =
                              counter.selectedCardsFromThirdRow.length == 5;

                          return ElevatedButton(
                            onPressed: isButtonEnabled
                                ? () async {
                                    calculateScores();
                                    context.read<CardsProvider>().putCards();
                                    setState(() {
                                      showWhiteText = true;
                                      isPlay = true;
                                    });

                                    if (_status == AnimationStatus.dismissed) {
                                      _controller.forward();
                                    } else {
                                      _controller.reverse();
                                    }

                                    await Future.delayed(
                                        const Duration(seconds: 4));
                                    await player
                                        .play(AssetSource('Music/Play.mp3'));
                                    var result = await _calculateScores();
                                    if (result == true) {
                                      context
                                          .read<CardsProvider>()
                                          .incrementCurrentRound();
                                      context
                                          .read<CardsProvider>()
                                          .removeCards();

                                      Navigator.of(context).pushNamed('/game');
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(6, 30),
                              backgroundColor: isButtonEnabled
                                  ? const Color(0xFFD3BF8F)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                            ),
                            child: Text(
                              "Play",
                              style: TextStyle(
                                fontFamily: "BreatheFire",
                                fontSize: 20,
                                color: isButtonEnabled
                                    ? const Color.fromARGB(255, 228, 231, 239)
                                    : Colors.white.withOpacity(
                                        0.5), // Disabled text color
                              ),
                            ),
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Scaffold(
                                  backgroundColor:
                                      Colors.black.withOpacity(0.8),
                                  body: Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: const AssetImage(
                                                'assets/images/background.png'),
                                            fit: BoxFit.fill,
                                            colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.8),
                                                BlendMode.darken)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: 20,
                                              child: Container(
                                                  decoration:
                                                      const BoxDecoration(),
                                                  child: const Text(""))),

                                          //joker-grid
                                          SizedBox(
                                            height: 400,
                                            width: 270,
                                            child: Container(
                                              child: GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  mainAxisSpacing: 1,
                                                  crossAxisSpacing: 1,
                                                ),
                                                itemCount: context
                                                    .read<CardsProvider>()
                                                    .jokerFirstScreenAssets
                                                    .length,
                                                // shuffleDeck(deck).length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          var jokerName = context
                                                                  .read<
                                                                      CardsProvider>()
                                                                  .jokerFirstScreenAssets[
                                                              index]["text"];
                                                          if (jokerName ==
                                                              "VISOR") {
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                                    '/game');

                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .visorShow();
                                                          } else if (jokerName ==
                                                              "HANDBONUS") {
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                                    '/game');

                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .handBonusShow();
                                                          } else if (jokerName ==
                                                              "EMPTYBONUS") {
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                                    '/game');

                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .emptyBonusShow();
                                                          } else if (jokerName ==
                                                              "SCORE") {
                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .scoreX2();
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                                    '/game');
                                                          } else if (jokerName ==
                                                              "FAKE") {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Scaffold(
                                                                  backgroundColor: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.8),
                                                                  body: Container(
                                                                      height: double.infinity,
                                                                      width: double.infinity,
                                                                      decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image:
                                                                                const AssetImage('assets/images/background.png'),
                                                                            fit: BoxFit.cover,
                                                                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                      ),
                                                                      child: Column(
                                                                        // MainAxisAlignment.spaceAround,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 50,
                                                                              child: Container(decoration: const BoxDecoration(), child: Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"]))),
                                                                          SizedBox(
                                                                            height:
                                                                                400,
                                                                            width:
                                                                                330,
                                                                            child:
                                                                                Container(
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"], style: const TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                  const SizedBox(height: 27),
                                                                                  Container(
                                                                                    height: 240,
                                                                                    width: double.infinity,
                                                                                    child: GridView.builder(
                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                        crossAxisCount: 4,
                                                                                        mainAxisSpacing: 7,
                                                                                        crossAxisSpacing: 11,
                                                                                      ),
                                                                                      itemCount: context.read<CardsProvider>().selectedCards.length,
                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            var selectedCardToFake = context.read<CardsProvider>().selectedCards[index];
                                                                                            List<String> selectedCardsToCopy = context.read<CardsProvider>().selectedCards.where((card) => card != selectedCardToFake).toList();

                                                                                            showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return Scaffold(
                                                                                                  backgroundColor: Colors.black.withOpacity(0.8),
                                                                                                  body: Container(
                                                                                                      height: double.infinity,
                                                                                                      width: double.infinity,
                                                                                                      decoration: BoxDecoration(
                                                                                                        image: DecorationImage(image: const AssetImage('assets/images/background.png'), fit: BoxFit.fill, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          SizedBox(
                                                                                                            height: 700,
                                                                                                            width: 330,
                                                                                                            child: Container(
                                                                                                              decoration: const BoxDecoration(),
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  const Text("Select A Card To Copy", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                                                  const SizedBox(height: 27),
                                                                                                                  Container(
                                                                                                                    height: 240,
                                                                                                                    width: double.infinity,
                                                                                                                    child: GridView.builder(
                                                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                                                        crossAxisCount: 3,
                                                                                                                        mainAxisSpacing: 7,
                                                                                                                        crossAxisSpacing: 11,
                                                                                                                      ),
                                                                                                                      itemCount: selectedCardsToCopy.length,
                                                                                                                      // shuffleDeck(deck).length,
                                                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                                                        return GestureDetector(
                                                                                                                          onTap: () {
                                                                                                                            var selectedCardToCopy = selectedCardsToCopy[index];
                                                                                                                            context.read<CardsProvider>().jokerFake(selectedCardToFake, selectedCardToCopy);
                                                                                                                            Navigator.pushNamed(context, '/game');
                                                                                                                          },
                                                                                                                          child: Container(
                                                                                                                            width: 5,
                                                                                                                            height: 5,
                                                                                                                            decoration: const BoxDecoration(
                                                                                                                              color: Color(0xFF838796),
                                                                                                                            ),
                                                                                                                            child: Container(
                                                                                                                                decoration: BoxDecoration(
                                                                                                                                    border: Border.all(
                                                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                                                    ),
                                                                                                                                    image: DecorationImage(image: AssetImage(selectedCardsToCopy[index])))),
                                                                                                                          ),
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  const SizedBox(height: 13),
                                                                                                                  GestureDetector(
                                                                                                                      onTap: () {
                                                                                                                        Navigator.pushNamed(context, '/game');
                                                                                                                      },
                                                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      )),
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                          child: Container(
                                                                                            width: 5,
                                                                                            height: 5,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Color(0xFF838796),
                                                                                              // border: Border.all(
                                                                                              //   color: Colors.white,
                                                                                              // ),
                                                                                            ),
                                                                                            child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                    ),
                                                                                                    image: DecorationImage(image: AssetImage(context.read<CardsProvider>().selectedCards[index])))),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(height: 13),
                                                                                  GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pushNamed(context, '/game');
                                                                                      },
                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                );
                                                              },
                                                            );
                                                          } else if (jokerName ==
                                                              "SUIT") {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Scaffold(
                                                                  backgroundColor: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.8),
                                                                  body: Container(
                                                                      height: double.infinity,
                                                                      width: double.infinity,
                                                                      decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image:
                                                                                const AssetImage('assets/images/background.png'),
                                                                            fit: BoxFit.fill,
                                                                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                      ),
                                                                      child: Column(
                                                                        // MainAxisAlignment.spaceAround,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 50,
                                                                              child: Container(decoration: const BoxDecoration(), child: Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"]))),
                                                                          SizedBox(
                                                                            height:
                                                                                400,
                                                                            width:
                                                                                330,
                                                                            child:
                                                                                Container(
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"], style: const TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                  const SizedBox(height: 27),
                                                                                  Container(
                                                                                    height: 240,
                                                                                    width: double.infinity,
                                                                                    child: GridView.builder(
                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                        crossAxisCount: 4,
                                                                                        mainAxisSpacing: 7,
                                                                                        crossAxisSpacing: 11,
                                                                                      ),
                                                                                      itemCount: context.read<CardsProvider>().selectedCards.length,
                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            var selectedCardToSuit = context.read<CardsProvider>().selectedCards[index];
                                                                                            List<String> selectedCardsToCopy = generateSuits(selectedCardToSuit);
                                                                                            showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return Scaffold(
                                                                                                  backgroundColor: Colors.black.withOpacity(0.8),
                                                                                                  body: Container(
                                                                                                      height: double.infinity,
                                                                                                      width: double.infinity,
                                                                                                      decoration: BoxDecoration(
                                                                                                        image: DecorationImage(image: const AssetImage('assets/images/background.png'), fit: BoxFit.fill, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          SizedBox(height: 50, child: Container(decoration: const BoxDecoration(), child: const Text("Select a card to change suit"))),
                                                                                                          SizedBox(
                                                                                                            height: 700,
                                                                                                            width: 330,
                                                                                                            child: Container(
                                                                                                              decoration: const BoxDecoration(),
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  const Text("Select New Suit", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                                                  const SizedBox(height: 27),
                                                                                                                  Container(
                                                                                                                    height: 240,
                                                                                                                    width: double.infinity,
                                                                                                                    child: GridView.builder(
                                                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                                                        crossAxisCount: 3,
                                                                                                                        mainAxisSpacing: 7,
                                                                                                                        crossAxisSpacing: 11,
                                                                                                                      ),
                                                                                                                      itemCount: selectedCardsToCopy.length,
                                                                                                                      // shuffleDeck(deck).length,
                                                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                                                        return GestureDetector(
                                                                                                                          onTap: () {
                                                                                                                            var selectedCardToCopy = selectedCardsToCopy[index];
                                                                                                                            context.read<CardsProvider>().jokerSuit(selectedCardToSuit, selectedCardToCopy);
                                                                                                                            Navigator.pushNamed(context, '/game');
                                                                                                                          },
                                                                                                                          child: Container(
                                                                                                                            width: 5,
                                                                                                                            height: 5,
                                                                                                                            decoration: const BoxDecoration(
                                                                                                                              color: Color(0xFF838796),
                                                                                                                            ),
                                                                                                                            child: Container(
                                                                                                                                decoration: BoxDecoration(
                                                                                                                                    border: Border.all(
                                                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                                                    ),
                                                                                                                                    image: DecorationImage(image: AssetImage(selectedCardsToCopy[index])))),
                                                                                                                          ),
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  const SizedBox(height: 13),
                                                                                                                  GestureDetector(
                                                                                                                      onTap: () {
                                                                                                                        Navigator.pushNamed(context, '/game');
                                                                                                                      },
                                                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      )),
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                          child: Container(
                                                                                            width: 5,
                                                                                            height: 5,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Color(0xFF838796),
                                                                                              // border: Border.all(
                                                                                              //   color: Colors.white,
                                                                                              // ),
                                                                                            ),
                                                                                            child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                    ),
                                                                                                    image: DecorationImage(image: AssetImage(context.read<CardsProvider>().selectedCards[index])))),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(height: 13),
                                                                                  GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pushNamed(context, '/game');
                                                                                      },
                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                );
                                                              },
                                                            );
                                                          } else if (jokerName ==
                                                              "EXTRACHANGE") {
                                                            context
                                                                .read<
                                                                    CardsProvider>()
                                                                .extraChanges();
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                                    '/game');
                                                          } else if (jokerName ==
                                                              "TRUMP") {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Scaffold(
                                                                  backgroundColor: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.8),
                                                                  body: Container(
                                                                      height: double.infinity,
                                                                      width: double.infinity,
                                                                      decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image:
                                                                                const AssetImage('assets/images/background.png'),
                                                                            fit: BoxFit.fill,
                                                                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                      ),
                                                                      child: Column(
                                                                        // MainAxisAlignment.spaceAround,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 50,
                                                                              child: Container(decoration: const BoxDecoration(), child: Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"]))),
                                                                          SizedBox(
                                                                            height:
                                                                                400,
                                                                            width:
                                                                                330,
                                                                            child:
                                                                                Container(
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"], style: const TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                  const SizedBox(height: 27),
                                                                                  Container(
                                                                                    height: 240,
                                                                                    width: double.infinity,
                                                                                    child: GridView.builder(
                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                        crossAxisCount: 4,
                                                                                        mainAxisSpacing: 7,
                                                                                        crossAxisSpacing: 11,
                                                                                      ),
                                                                                      itemCount: context.read<CardsProvider>().selectedCards.length,
                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            var selectedCardToSwap = context.read<CardsProvider>().selectedCards[index];
                                                                                            List<String> selectedCardsToCopy = context.read<CardsProvider>().remainingDeckElements;
                                                                                            showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return Scaffold(
                                                                                                  backgroundColor: Colors.black.withOpacity(0.8),
                                                                                                  body: Container(
                                                                                                      height: double.infinity,
                                                                                                      width: double.infinity,
                                                                                                      decoration: BoxDecoration(
                                                                                                        image: DecorationImage(image: const AssetImage('assets/images/background.png'), fit: BoxFit.fill, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          SizedBox(height: 50, child: Container(decoration: const BoxDecoration(), child: const Text("Select a card to change suit"))),
                                                                                                          SizedBox(
                                                                                                            height: 700,
                                                                                                            width: 330,
                                                                                                            child: Container(
                                                                                                              decoration: const BoxDecoration(),
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  const Text("Select A Card To Copy", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                                                  const SizedBox(height: 27),
                                                                                                                  Container(
                                                                                                                    height: 240,
                                                                                                                    width: double.infinity,
                                                                                                                    child: GridView.builder(
                                                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                                                        crossAxisCount: 3,
                                                                                                                        mainAxisSpacing: 7,
                                                                                                                        crossAxisSpacing: 11,
                                                                                                                      ),
                                                                                                                      itemCount: selectedCardsToCopy.length,
                                                                                                                      // shuffleDeck(deck).length,
                                                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                                                        return GestureDetector(
                                                                                                                          onTap: () {
                                                                                                                            var selectedCardToCopy = selectedCardsToCopy[index];
                                                                                                                            context.read<CardsProvider>().trump(selectedCardToSwap, selectedCardToCopy);
                                                                                                                            Navigator.pushNamed(context, '/game');
                                                                                                                          },
                                                                                                                          child: Container(
                                                                                                                            width: 5,
                                                                                                                            height: 5,
                                                                                                                            decoration: const BoxDecoration(
                                                                                                                              color: Color(0xFF838796),
                                                                                                                            ),
                                                                                                                            child: Container(
                                                                                                                                decoration: BoxDecoration(
                                                                                                                                    border: Border.all(
                                                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                                                    ),
                                                                                                                                    image: DecorationImage(image: AssetImage(selectedCardsToCopy[index])))),
                                                                                                                          ),
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  const SizedBox(height: 13),
                                                                                                                  GestureDetector(
                                                                                                                      onTap: () {
                                                                                                                        Navigator.pushNamed(context, '/game');
                                                                                                                      },
                                                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      )),
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                          child: Container(
                                                                                            width: 5,
                                                                                            height: 5,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Color(0xFF838796),
                                                                                            ),
                                                                                            child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                    ),
                                                                                                    image: DecorationImage(image: AssetImage(context.read<CardsProvider>().selectedCards[index])))),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(height: 13),
                                                                                  GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pushNamed(context, '/game');
                                                                                      },
                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                );
                                                              },
                                                            );
                                                          } else if (jokerName ==
                                                              "TRANSFORMER") {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Scaffold(
                                                                  backgroundColor: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.8),
                                                                  body: Container(
                                                                      height: double.infinity,
                                                                      width: double.infinity,
                                                                      decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image:
                                                                                const AssetImage('assets/images/background.png'),
                                                                            fit: BoxFit.fill,
                                                                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                      ),
                                                                      child: Column(
                                                                        // MainAxisAlignment.spaceAround,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 50,
                                                                              child: Container(decoration: const BoxDecoration(), child: Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"]))),
                                                                          SizedBox(
                                                                            height:
                                                                                400,
                                                                            width:
                                                                                330,
                                                                            child:
                                                                                Container(
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(context.read<CardsProvider>().jokerFirstScreenAssets[index]["additionalText"], style: const TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                  const SizedBox(height: 27),
                                                                                  Container(
                                                                                    height: 240,
                                                                                    width: double.infinity,
                                                                                    child: GridView.builder(
                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                        crossAxisCount: 4,
                                                                                        mainAxisSpacing: 7,
                                                                                        crossAxisSpacing: 11,
                                                                                      ),
                                                                                      itemCount: context.read<CardsProvider>().selectedCards.length,
                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            var selectedCardToSwap = context.read<CardsProvider>().selectedCards[index];
                                                                                            List<String> selectedCardsToCopy = generateDeck();
                                                                                            showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return Scaffold(
                                                                                                  backgroundColor: Colors.black.withOpacity(0.8),
                                                                                                  body: Container(
                                                                                                      height: double.infinity,
                                                                                                      width: double.infinity,
                                                                                                      decoration: BoxDecoration(
                                                                                                        image: DecorationImage(image: const AssetImage('assets/images/background.png'), fit: BoxFit.fill, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken)),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          SizedBox(height: 50, child: Container(decoration: const BoxDecoration(), child: const Text("Select a card to change suit"))),
                                                                                                          SizedBox(
                                                                                                            height: 700,
                                                                                                            width: 330,
                                                                                                            child: Container(
                                                                                                              decoration: const BoxDecoration(),
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  const Text("Select A Card To Transform into", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22)),
                                                                                                                  const SizedBox(height: 27),
                                                                                                                  Container(
                                                                                                                    height: 240,
                                                                                                                    width: double.infinity,
                                                                                                                    child: GridView.builder(
                                                                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                                                        crossAxisCount: 3,
                                                                                                                        mainAxisSpacing: 7,
                                                                                                                        crossAxisSpacing: 11,
                                                                                                                      ),
                                                                                                                      itemCount: selectedCardsToCopy.length,
                                                                                                                      // shuffleDeck(deck).length,
                                                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                                                        return GestureDetector(
                                                                                                                          onTap: () {
                                                                                                                            var selectedCardToCopy = selectedCardsToCopy[index];
                                                                                                                            context.read<CardsProvider>().transform(selectedCardToSwap, selectedCardToCopy);
                                                                                                                            Navigator.pushNamed(context, '/game');
                                                                                                                          },
                                                                                                                          child: Container(
                                                                                                                            width: 5,
                                                                                                                            height: 5,
                                                                                                                            decoration: const BoxDecoration(
                                                                                                                              color: Color(0xFF838796),
                                                                                                                            ),
                                                                                                                            child: Container(
                                                                                                                                decoration: BoxDecoration(
                                                                                                                                    border: Border.all(
                                                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                                                    ),
                                                                                                                                    image: DecorationImage(image: AssetImage(selectedCardsToCopy[index])))),
                                                                                                                          ),
                                                                                                                        );
                                                                                                                      },
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  const SizedBox(height: 13),
                                                                                                                  GestureDetector(
                                                                                                                      onTap: () {
                                                                                                                        Navigator.pushNamed(context, '/game');
                                                                                                                      },
                                                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      )),
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                          child: Container(
                                                                                            width: 5,
                                                                                            height: 5,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Color(0xFF838796),
                                                                                            ),
                                                                                            child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      color: const Color.fromARGB(0, 0, 0, 0),
                                                                                                    ),
                                                                                                    image: DecorationImage(image: AssetImage(context.read<CardsProvider>().selectedCards[index])))),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(height: 13),
                                                                                  GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pushNamed(context, '/game');
                                                                                      },
                                                                                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontFamily: "BreatheFire", fontSize: 22))),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                );
                                                              },
                                                            );
                                                          }
                                                          var box = await Hive
                                                              .openBox("myBox");
                                                          var b =
                                                              Hive.box("myBox");

                                                          b.put(
                                                              "noOfChips",
                                                              context
                                                                  .read<
                                                                      CardsProvider>()
                                                                  .noOfChips);
                                                          b.put(
                                                              "level",
                                                              context
                                                                  .read<
                                                                      CardsProvider>()
                                                                  .currentLevel);
                                                          b.put(
                                                              "purchaseJokers",
                                                              context
                                                                  .read<
                                                                      CardsProvider>()
                                                                  .purchaseJokers);
                                                          b.put(
                                                              "purchaseCards",
                                                              context
                                                                  .read<
                                                                      CardsProvider>()
                                                                  .purchaseCards);
                                                        },
                                                        child: Container(
                                                            height: 70,
                                                            width: 70,
                                                            decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                    image: AssetImage(context
                                                                            .read<
                                                                                CardsProvider>()
                                                                            .jokerFirstScreenAssets[index]
                                                                        [
                                                                        "imageUrl"]),
                                                                    fit: BoxFit
                                                                        .fill))),
                                                      ),
                                                      Text(
                                                          context
                                                                  .read<
                                                                      CardsProvider>()
                                                                  .jokerFirstScreenAssets[
                                                              index]["text"],
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  "BreatheFire",
                                                              fontSize: 18)),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                );
                              },
                            );
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
                      Consumer<CardsProvider>(
                          builder: (context, counter, child) {
                        final bool isButtonEnabled =
                            counter.remainingDeckView > 0 &&
                                counter.selectedCardsFromThirdRow.isNotEmpty;

                        return Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                image: const DecorationImage(
                                    image: const AssetImage(
                                        'assets/images/button_border.png'),
                                    fit: BoxFit.fill)),
                            child: ElevatedButton(
                              onPressed: isButtonEnabled
                                  ? () {
                                      if (counter.remainingDeckView > 0 &&
                                          counter.selectedCardsFromThirdRow
                                              .isNotEmpty) {
                                        context
                                            .read<CardsProvider>()
                                            .swapFunctionality();
                                        // swapButtonPress();
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(6, 30),
                                backgroundColor: isButtonEnabled
                                    ? const Color(0xFFD3BF8F)
                                    : Colors.grey, // Disabled color
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: SvgPicture.asset(
                                      'assets/images/rewind.svg',
                                      width: 20,
                                      color: isButtonEnabled
                                          ? null
                                          : Colors.white.withOpacity(
                                              0.5), // Disabled icon color
                                    ),
                                  ),
                                  Text(
                                    counter.remainingDeckView.toString(),
                                    style: TextStyle(
                                      color: isButtonEnabled
                                          ? Colors.white
                                          : Colors.white.withOpacity(
                                              0.5), // Disabled text color
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      }),

                      //cards-grid
                      Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () {
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
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return SelectableCard(
                                                      imageUrl: counter
                                                              .remainingDeckElements[
                                                          index],
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
                                width: 45,
                                height: 50,
                                child: const Text("")),
                          ),
                          Consumer<CardsProvider>(
                              builder: (context, counter, child) {
                            return Text(
                                '${counter.remainingDeckElements.length}/${counter.remainingDeckElements.length + counter.discardedDeckElements.length + counter.selectedCards.length}');
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
            ? const BorderSide(color: Color.fromARGB(255, 2, 178, 34), width: 5)
            : BorderSide.none,
      ),
      child: Consumer<CardsProvider>(
        builder: (context, counter, child) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _isSelected = !_isSelected;

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
                Image.asset(widget.imageUrl),
                // Text(widget.title),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SelectableCardForUpgrade extends StatefulWidget {
  final String imageUrl;
  final int cost;
  final bool isPurchased;
  SelectableCardForUpgrade({
    required this.imageUrl,
    required this.cost,
    required this.isPurchased,
  });

  @override
  _SelectableCardForUpgradeState createState() =>
      _SelectableCardForUpgradeState();
}

class _SelectableCardForUpgradeState extends State<SelectableCardForUpgrade> {
  bool _isSelected = false;
  bool insufficientBalance = false;
  void initState() {
    super.initState();
    openBox();
  }

  var b = Hive.box("myBox");
  void openBox() async {
    var box = await Hive.openBox("myBox");
    context.read<CardsProvider>().updateChipsInProvider(b.get("noOfChips"),
        b.get("level"), b.get("purchaseJokers"), b.get("purchaseCards"));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF838796),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: _isSelected
            ? const BorderSide(color: Color.fromARGB(255, 2, 178, 34), width: 5)
            : BorderSide.none,
      ),
      child: Consumer<CardsProvider>(
        builder: (context, counter, child) {
          return GestureDetector(
            onTap: () async {
              setState(() {
                _isSelected = !_isSelected;
              });

              if (_isSelected == false) {
              } else {
                var noOFChips = context.read<CardsProvider>().noOfChips;
                if (noOFChips >= widget.cost) {
                } else {
                  setState(() {
                    _isSelected = !_isSelected;
                    insufficientBalance = true;
                  });
                }
              }

              insufficientBalance == true
                  ? showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          elevation: 20,
                          backgroundColor: const Color(0xFF838796),
                          title: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(widget.imageUrl),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          content: Text(
                              'Insufficient Balance To Purchase This Card For ${widget.cost}',
                              style: const TextStyle(
                                  fontFamily: "BreatheFire",
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 252, 252, 252))),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Ok',
                                      style: TextStyle(
                                          fontFamily: "BreatheFire",
                                          fontSize: 21,
                                          color: Color.fromARGB(
                                              255, 252, 252, 252))),
                                ),
                              ],
                            )
                          ],
                        );
                      })
                  : widget.isPurchased == false
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: 20,
                              backgroundColor: const Color(0xFF838796),
                              title: Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(widget.imageUrl),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              content: Text(
                                  'Do You Want To Purchase This Card For ${widget.cost}',
                                  style: const TextStyle(
                                      fontFamily: "BreatheFire",
                                      fontSize: 20,
                                      color:
                                          Color.fromARGB(255, 252, 252, 252))),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        context
                                            .read<CardsProvider>()
                                            .addPurchasedCard(
                                                widget.imageUrl, widget.cost);
                                        b.put("noOfChips", counter.noOfChips);
                                        b.put("level", counter.currentLevel);
                                        b.put("purchaseJokers",
                                            counter.purchaseJokers);
                                        b.put("purchaseCards",
                                            counter.purchaseCards);
                                      },
                                      child: const Text('Yes',
                                          style: TextStyle(
                                              fontFamily: "BreatheFire",
                                              fontSize: 21,
                                              color: Color.fromARGB(
                                                  255, 252, 252, 252))),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('No',
                                          style: TextStyle(
                                              fontFamily: "BreatheFire",
                                              fontSize: 21,
                                              color: Color.fromARGB(
                                                  255, 252, 252, 252))),
                                    ),
                                  ],
                                )
                              ],
                            );
                          })
                      : null;
            },
            child: Container(
              child: Column(
                children: [
                  Image.asset(widget.imageUrl, height: 50),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (widget.isPurchased == false)
                      SvgPicture.asset(
                        'assets/images/upgrade-card-2.svg',
                        fit: BoxFit.cover,
                        // width: 49,
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (widget.isPurchased == false)
                      Text('${widget.cost}',
                          style: const TextStyle(
                              fontFamily: "BreatheFire",
                              fontSize: 17,
                              color: Color.fromARGB(255, 252, 252, 252))),
                  ])
                  // Text(${widget.cost})
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
