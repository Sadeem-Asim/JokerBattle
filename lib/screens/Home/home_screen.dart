// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/blocs.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/provider/card_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:games_services/games_services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => HomeScreen(),
    );
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  final player = AudioPlayer();
  bool isContinue = false;

  // Set the release mode to keep the source after playback has completed.
  // player.setReleaseMode();
  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    try {
      player.play(AssetSource('Music/BG.mp3'));
      var box = await Hive.openBox("myBox");
      var b = Hive.box("myBox");
      if (b.get("level") != null && b.get("round") != null) {
        var currentLevel = b.get("level");
        var currentRound = b.get("round");
        if (currentLevel > 1 && currentRound >= 1) {
          setState(() {
            isContinue = true;
          });
          context.read<CardsProvider>().updateChipsInProvider(
              b.get("noOfChips"),
              b.get("level"),
              b.get("purchaseJokers"),
              b.get("purchaseCards"),
              b.get("round"),
              b.get("remainingDeckElements"),
              b.get("remainingAiElements"),
              b.get("selectedCards"),
              b.get("selectedCardsFromThirdRow"),
              b.get("discardedDeckElements"),
              b.get("selectedCardsForAi"),
              b.get("playerScore"),
              b.get("aiScore"),
              b.get("remainingDeckView") // Ensure this exists in `b`
              );
        }
      }
    } catch (e) {
      print("Print error in here");
      print(e);
    }
  }

  @override
  void dispose() {
    AudioPlayer().dispose(); // Clean up the audio player
    super.dispose(); // Call the parent class's dispose method
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
          alignment: Alignment.center,
          // padding: EdgeInsets.all(),
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<CardsProvider>(builder: (context, counter, child) {
                  return isContinue
                      ? ElevatedButton(
                          onPressed: () async {
                            player.stop();
                            context
                                .read<CardsProvider>()
                                .removeCardsOnContinueClick();
                            Navigator.pushNamed(context, '/game');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF838796),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 110, vertical: 8),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                                fontFamily: "BreatheFire", fontSize: 32),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            player.stop();
                            context
                                .read<CardsProvider>()
                                .removeCardsOnGameClick();
                            Navigator.pushNamed(context, '/game');
                          },
                          child: const Text(
                            'Game',
                            style: TextStyle(
                                fontFamily: "BreatheFire", fontSize: 32),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF838796),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 110, vertical: 8),
                          ),
                        );
                }),

                // // ElevatedButton(
                //   onPressed: () {
                //     // Handle button 1 press
                //   },

                //   style: ElevatedButton.styleFrom(
                //       // elevation: 30,

                //       //                 horizontal: 5, vertical: 12),
                //       backgroundColor: Color(0xFF838796),

                //       // padding: EdgeInsets.zero,
                //       padding: EdgeInsets.all(
                //           32),

                //       // shape: RoundedRectangleBorder(
                //       //   side: BorderSide(
                //       //     color: Color.fromARGB(255, 153, 144, 144),
                //       //     width: 5,
                //       //     // Adjust the width of the border
                //       //   ),
                //       //   borderRadius: BorderRadius.circular(10),
                //       //   // visualDensity: ,
                //       //   // backgroundColor: Colors.grey
                //       // )

                //       ),

                //   child:
                //   // //  Container(

                //   // //   width: 220,
                //   // //   height: 45,
                //   // //   child: Stack(
                //   // //     children: [
                //   // //       SvgPicture.asset(
                //   // //         'assets/images/Vector.svg',
                //   // //         fit: BoxFit.cover,
                //   // //         // width: 49,
                //   // //       ),
                //         Center(
                //           child: Text(
                //             'Game',
                //             style: TextStyle(
                //               fontSize: 16,
                //               color: Color(
                //                     0xFF838796) // Adjust the text color as needed
                //             ),
                //           ),
                //         ),
                // //       ],
                // //     ),
                // //   ),
                // ),

                SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/info');
                  },
                  child: const Text('Info',
                      style:
                          TextStyle(fontFamily: "BreatheFire", fontSize: 32)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF838796),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 120, vertical: 8),
                  ),
                ),
                SizedBox(height: 18),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        final result = await GamesServices.loadAchievements();
                        print(result);
                        print({"koila": result});
                        // Handle button 2 press
                        final resulti = await GamesServices.showAchievements();
                      } catch (e) {
                        print({"jilii": e});
                      }
                      ;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF838796),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    ),
                    child: Image.asset(
                      "assets/images/third.png",
                    ))
              ],
            ),
          )

          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     const  Center(
          //       child:
          //       Image(
          //         image: AssetImage('assets/images/background.png'),
          //         width: 125,
          //         height: 125,
          //       ),
          //     ),
          //     const SizedBox(height: 30),
          //     Container(
          //       color: const Color.fromARGB(255, 255, 255, 255),
          //       padding: const EdgeInsets.symmetric(
          //         vertical: 10,
          //         horizontal: 20,
          //       ),
          //       child: Text(
          //         'NexaTech',
          //         style: Theme.of(context).textTheme.titleLarge!.copyWith(
          //               color: Color.fromARGB(255, 1, 209, 147),
          //             ),
          //       ),
          //     )
          //   ],
          // ),
          ));
}
