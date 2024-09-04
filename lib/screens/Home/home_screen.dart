import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:joker_battle/screens/Game/game_screen.dart';
// import '../../blocs/blocs.dart';
import 'package:provider/provider.dart';
import 'package:joker_battle/utils/game.dart';
import 'package:joker_battle/provider/card_provider.dart';
import 'package:audioplayers/audioplayers.dart';

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
  List<String> deck = generateDeck();
  final player = AudioPlayer();

  // Set the release mode to keep the source after playback has completed.
  // player.setReleaseMode();
  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    player.play(AssetSource('Music/BG.mp3'));
  }

  @override
  void dispose() {
    print("harami-d");
    AudioPlayer().dispose(); // Clean up the audio player
    super.dispose(); // Call the parent class's dispose method
  }

  @override
  Widget build(BuildContext context) =>
      // Timer(
      //   const Duration(seconds: 04),
      //   () => Navigator.pushNamed(context, '/'),
      // );

      Scaffold(
          // backgroundColor: Color.fromARGB(255, 223, 22, 22),
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
                      return ElevatedButton(
                        onPressed: () async {
                          player.stop();
                          context
                              .read<CardsProvider>()
                              .shuffleDeckElement(deck);
                          context
                              .read<CardsProvider>()
                              .removeCardsOnGameClick();
                          //  context
                          //     .read<AICardsProvider>()
                          //     .removeCards();
                          // .addMultipleCards(selectedCards);
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
                          style: TextStyle(
                              fontFamily: "BreatheFire", fontSize: 32)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF838796),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 120, vertical: 8),
                      ),
                    ),
                    SizedBox(height: 18),
                    ElevatedButton(
                        onPressed: () {
                          // Handle button 2 press
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF838796),
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 20),
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
