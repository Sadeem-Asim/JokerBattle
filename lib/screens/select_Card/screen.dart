import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectCardsScreen extends StatefulWidget {
  static const String routeName = '/selectCards';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => SelectCardsScreen(),
    );
  }

  @override
  State<SelectCardsScreen> createState() => _SelectCardsScreenState();
}

class _SelectCardsScreenState extends State<SelectCardsScreen> {
  int _selectedButtonIndex = 0;

  void _onButtonPressed(int index) {
    setState(() {
      _selectedButtonIndex = index;
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

    final List<String> cardData = [
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
      'transparent.png',
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
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: cardData.length,
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
                                                    'assets/images/${cardData[index]}'),
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
                                    SizedBox(
                                      height: 70,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: secondCardData.length,
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
                                                        'assets/images/${secondCardData[index]}'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 9,
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    ),
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
                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: ThirdCardData.length,
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
                                                    'assets/images/${ThirdCardData[index]}'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
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
























                
              
              ],
            ))

        // )

        );
  }
}
