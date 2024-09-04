import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/utils/game.dart';
import 'package:joker_battle/provider/card_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import "package:path_provider/path_provider.dart";
import 'dart:io';
import 'package:joker_battle/widgets/flip.dart';
import 'package:flip_card/flip_card.dart';

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
  int remainingDeckView = 3;
  var box = Hive.openBox('noOfChips');
  final player = AudioPlayer();
  bool showWhiteText = false;
  bool isPlay = false;

  final List<Map<String, dynamic>> upgradeArray = [
    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},
    // {"imageUrl": "assets/images/card_spades_09.png", "cost": 10},
    // {"imageUrl": "assets/images/card_spades_10.png", "cost": 10},

    // {"imageUrl": "assets/images/card_spades_J.png", "cost": 13},
    // {"imageUrl": "assets/images/card_spades_K.png", "cost": 15},
    // {"imageUrl": "assets/images/card_spades_Q.png", "cost": 17},
    // {"imageUrl": "assets/images/card_clubs_A.png", "cost": 20},
    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    {"imageUrl": "assets/images/card_clubs_02.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_03.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_04.png", "cost": 5},
    {"imageUrl": "assets/images/card_clubs_05.png", "cost": 8},
    // {"imageUrl": "assets/images/card_clubs_06.png", "cost": 8},
    // {"imageUrl": "assets/images/card_clubs_07.png", "cost": 8},

    // {"imageUrl": "assets/images/", "cost":5},
    // {"imageUrl": "assets/images/", "cost":5}
  ];

  void swapButtonPress() {
    remainingDeckView > 0 ? setState(() => remainingDeckView--) : null;
  }

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

  Future _calculateScores(int noOfChips) async {
    List<String> userSelectedCards =
        context.read<CardsProvider>().selectedCardsFromThirdRow;

    playerScore = calculateScore(userSelectedCards);
    setState(() {
      playerScore = playerScore;
    });
    context.read<CardsProvider>().setPlayerScore(
        (context.read<CardsProvider>().playerScore) + playerScore);

    List<String> aiSelectedCards =
        context.read<CardsProvider>().selectedCardsForAi;
    aiScore = calculateScore(aiSelectedCards);

    setState(() {
      aiScore = aiScore;
    });
    context
        .read<CardsProvider>()
        .setAiScore((context.read<CardsProvider>().aiScore) + aiScore);
    bool winStatus = playerScore > aiScore ? true : true;

    if (Provider.of<CardsProvider>(context, listen: false).currentRound == 5) {
      await context.read<CardsProvider>().addTenChipsOnWin();
    }

    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    var box = await Hive.openBox('noOfChips', path: appDocumentDirectory.path);
    await box.put('noOfChips', context.read<CardsProvider>().noOfChips);

    if (winStatus == true) {
      Future.delayed(
          const Duration(seconds: 0, milliseconds: 70),
          () => {
                if (winStatus == true &&
                    Provider.of<CardsProvider>(context, listen: false)
                            .currentRound ==
                        5)
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
                                                  child: Text(
                                                      "${context.read<CardsProvider>().aiScore}",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              "BreatheFire",
                                                          fontSize: 14)),
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
                                                                      23))),
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
                                                  child: Text(
                                                      "${context.read<CardsProvider>().playerScore}",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              "BreatheFire",
                                                          fontSize: 14)),
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
                                                                      23))),
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
                                          child: const Text("Upgrade",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 35)),
                                          onPressed: () async {
                                            var box =
                                                await Hive.openBox('noOfChips');
                                            var noOfChips =
                                                box.get('noOfChips');
                                            await player.play(AssetSource(
                                                'Music/Upgrade.mp3'));

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
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
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
                                                                          8,
                                                                      vertical:
                                                                          8),
                                                            ),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/images/backbutton.svg',
                                                              fit: BoxFit.cover,
                                                              // width: 49,
                                                            ),
                                                            // ),
                                                          ),

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
                                                                  // crossAxisAlignment:
                                                                  //     CrossAxisAlignment.start,
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
                                                                        '${noOfChips}',
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
                                                          // const SizedBox(width: 15),
                                                        ]),
                                                    const SizedBox(height: 45),

                                                    //upgrade-grid
                                                    SizedBox(
                                                      height: 400,
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
                                                              itemCount:
                                                                  upgradeArray
                                                                      .length,
                                                              // shuffleDeck(deck).length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return SelectableCardForUpgrade(
                                                                    imageUrl: upgradeArray[
                                                                            index]
                                                                        [
                                                                        "imageUrl"],
                                                                    cost: upgradeArray[
                                                                            index]
                                                                        [
                                                                        "cost"]);
                                                              },
                                                            ));
                                                      }),
                                                    ),

                                                    //hook

                                                    context
                                                                .read<
                                                                    CardsProvider>()
                                                                .currentRound ==
                                                            5
                                                        ? ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              context
                                                                  .read<
                                                                      CardsProvider>()
                                                                  .incrementCurrentRound();

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
                                                              Navigator
                                                                  .pushNamed(
                                                                      context,
                                                                      '/game');
                                                            },
                                                            style:
                                                                ElevatedButton
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
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          85,
                                                                      vertical:
                                                                          8),
                                                            ),
                                                            child: const Text(
                                                              'NEXT LEVEL',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "BreatheFire",
                                                                  fontSize: 32),
                                                            ),
                                                          )
                                                        : ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              // context
                                                              //     .read<CardsProvider>()
                                                              //     .shuffleDeckElement(deck);
                                                              //     // context
                                                              //     // .read<CardsProvider>()
                                                              //     // .addMultipleCards(selectedCards);
                                                              // context
                                                              //     .read<CardsProvider>()
                                                              //     .incrementCurrentRound();
                                                              // context
                                                              //     .read<CardsProvider>()
                                                              //     .removeCards();

                                                              // context
                                                              // .read<CardsProvider>()
                                                              // .setPlayerScore((context
                                                              //         .read<CardsProvider>()
                                                              //         .playerScore) +
                                                              //     playerScore);

                                                              //     context
                                                              // .read<CardsProvider>()
                                                              // .setPlayerScore((context
                                                              //         .read<CardsProvider>()
                                                              //         .aiScore) +
                                                              //     aiScore);

                                                              // await player.play(AssetSource(
                                                              //     'Music/Round-start.mp3'));
                                                              Navigator
                                                                  .pushNamed(
                                                                      context,
                                                                      '/home');
                                                            },
                                                            child: const Text(
                                                              'Menu',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "BreatheFire",
                                                                  fontSize: 32),
                                                            ),
                                                            style:
                                                                ElevatedButton
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
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          85,
                                                                      vertical:
                                                                          8),
                                                            ),
                                                          )
                                                  ],
                                                );
                                              },
                                            );

                                            // Handle button 1 press
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
                                                      horizontal: 80))),
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
      //  context.read<CardsProvider>().setCurrentRound();
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
                              // color: Color(0xFF5C5E68),
                              // border: Border.all(
                              //   color: Color.fromARGB(255, 239, 239, 241), // Set the border color
                              //   width: 4,

                              //   // Set the border width
                              // ),
                              // borderRadius: BorderRadius.circular(20),
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
                                              child: Text("$aiScore",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "BreatheFire",
                                                      fontSize: 14)),
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
                                                      horizontal: 23))),
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
                                              child: Text("$playerScore",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "BreatheFire",
                                                      fontSize: 14)),
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
                                                      horizontal: 23))),
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
                                      child: const Text("MENU",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 30)),
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
                                              vertical: 0, horizontal: 80))),
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

  void _addToSelectedCards(String index) {
    setState(() {
      selectedCardsList
          .add(index); // Assuming ThirdCardData has an 'id' property
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      // const SizedBox(width: 15),
                    ]),
                const SizedBox(height: 45),
                Container(
                  height: 560,
                  child: Stack(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        showWhiteText
                            ? Row(
                                children: [
                                  Column(
                                    children: [
                                      Text("You Base Score:${playerScore}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 17)),
                                      const SizedBox(height: 7),
                                      Text(
                                          "Two Pair Bonus:${context.read<CardsProvider>().playerScore}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 14)),
                                      const SizedBox(height: 7),
                                      Text(
                                          "Total:${context.read<CardsProvider>().playerScore}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 14)),
                                      const SizedBox(height: 7),
                                    ],
                                  ),
                                  const SizedBox(width: 5)
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
                                  Text("Opponent Base Score:${aiScore}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: "BreatheFire",
                                          fontSize: 14)),
                                  Text(
                                      "High Card Bonus:${context.read<CardsProvider>().aiScore}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: "BreatheFire",
                                          fontSize: 14)),
                                  Text(
                                      "Total:${context.read<CardsProvider>().aiScore}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: "BreatheFire",
                                          fontSize: 14)),
                                ],
                              )
                            : const Text(""),
                      ],
                    ),
                    Positioned(
                      bottom: 22,
                      right: 147,
                      child: SvgPicture.asset(
                        'assets/images/kadoo-tail.svg',
                      ),
                    ),

                    //orange_circle
                    Positioned(
                      top: 70,
                      right: -4,
                      child: Container(
                          height: 390,
                          width: 390,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: const AssetImage(
                                    'assets/images/texture.png'),
                                fit: BoxFit.fill),
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
                                            AnimatedSwitcher(
                                              duration:
                                                  const Duration(seconds: 1),
                                              child: isPlay
                                                  ? Container(
                                                      width: 28,
                                                      height: 39,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            counter.selectedCardsForAi
                                                                        .length ==
                                                                    5
                                                                ? counter
                                                                        .selectedCardsForAi[
                                                                    index]
                                                                : "assets/images/${cardDataAI[index]}",
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 28,
                                                      height: 39,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            "assets/images/${cardDataAI[index]}",
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                              transitionBuilder:
                                                  (child, animation) =>
                                                      ScaleTransition(
                                                scale: animation,
                                                child: child,
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
                                      child: Text(
                                          "${context.read<CardsProvider>().aiScore}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: "BreatheFire",
                                              fontSize: 14)),
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
                                              vertical: 0, horizontal: 23))),
                                ),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    const SizedBox(
                                      width: 25,
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
                                                  fontSize: 23))
                                          //  SvgPicture.asset(
                                          //   'assets/images/threeRound.svg',
                                          //   fit: BoxFit.cover,
                                          //   width: 49,
                                          // ),
                                          );
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
                                        child: Text(
                                            "${context.read<CardsProvider>().playerScore}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: "BreatheFire",
                                                fontSize: 14)),
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF88E060),
                                            padding: const EdgeInsets.symmetric(
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
                                                final selectedCard = counter
                                                    .shuffleDeckElements[index];
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
                                                              .selectedCardToSwap
                                                              .contains(counter
                                                                      .selectedCards[
                                                                  index]) ||
                                                          counter
                                                              .selectedCardsFromThirdRow
                                                              .contains(counter
                                                                      .selectedCards[
                                                                  index])
                                                      ? Border.all(
                                                          color: const Color
                                                              .fromARGB(
                                                              255,
                                                              253,
                                                              187,
                                                              54), // Set the border color
                                                          width: 3,
                                                          // Set the border width
                                                        )
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        //if index<

//  '${(index)>=counter.selectedCards.length ? "assets/images/${cardData[index]}" : counter.selectedCards[index] }'),
                                                        counter.shuffleDeckElements[
                                                            index]),
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
                                    setState(() {
                                      showWhiteText = true;
                                      isPlay = true;
                                    });
                                    await Future.delayed(
                                        const Duration(seconds: 3));
                                    await player
                                        .play(AssetSource('Music/Play.mp3'));
                                    var result = await _calculateScores(
                                        counter.noOfChips);
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
                                      child: const Column(
                                        // MainAxisAlignment.spaceAround,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 250),
                                          SizedBox(
                                            height: 400,
                                            child: Text(
                                              "5 Jokers max",
                                              style: TextStyle(
                                                  fontFamily: "BreatheFire",
                                                  fontSize: 40,
                                                  color: Color(0xFFF7A74F)),
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
                        final bool isButtonEnabled = remainingDeckView > 0 &&
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
                                      if (remainingDeckView > 0 &&
                                          counter.selectedCardsFromThirdRow
                                              .isNotEmpty) {
                                        context
                                            .read<CardsProvider>()
                                            .swapFunctionality();
                                        swapButtonPress();
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
                                    "$remainingDeckView",
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
                                child: const Text(""),
                                width: 45,
                                height: 50),
                          ),
                          Consumer<CardsProvider>(
                              builder: (context, counter, child) {
                            return Text(
                                '${counter.remainingDeckElements.length}/${counter.remainingDeckElements.length + counter.purchaseCards.length + counter.discardedDeckElements.length}');
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

  SelectableCardForUpgrade({
    required this.imageUrl,
    required this.cost,
  });

  @override
  _SelectableCardForUpgradeState createState() =>
      _SelectableCardForUpgradeState();
}

class _SelectableCardForUpgradeState extends State<SelectableCardForUpgrade> {
  bool _isSelected = false;
  bool insufficientBalance = false;

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
            onTap: () {
              setState(() async {
                _isSelected = !_isSelected;

                // if (counter.selectedCards.length <= 5)
                // _isSelected = !_isSelected;

                if (_isSelected == false) {
                  context
                      .read<CardsProvider>()
                      .removeSingleCard(widget.imageUrl);
                } else {
                  var box = await Hive.openBox('noOfChips');
                  var noOFChips = await box.get('noOfChips');
                  // context.read<CardsProvider>().selectCards(widget.imageUrl);
                  if (noOFChips > widget.cost) {
                    await context
                        .read<CardsProvider>()
                        .addPurchasedCard(widget.imageUrl, widget.cost);
                  } else {
                    setState(() {
                      insufficientBalance = true;
                    });
                  }
                }
              });
              // if()

              insufficientBalance == true
                  ? showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Important Message'),
                          content: const Text('You have insfficient balance'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            )
                          ],
                        );
                      })
                  : showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Important Message'),
                          content: const Text('You have purchased a card'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            )
                          ],
                        );
                      });
            },
            child: Column(
              children: [
                Image.asset(widget.imageUrl),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SvgPicture.asset(
                    'assets/images/upgrade-card-2.svg',
                    fit: BoxFit.cover,
                    // width: 49,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('${widget.cost}',
                      style: const TextStyle(
                          fontFamily: "BreatheFire",
                          fontSize: 17,
                          color: Color.fromARGB(255, 252, 252, 252))),
                ])
                // Text(${widget.cost})
              ],
            ),
          );
        },
      ),
    );
  }
}
