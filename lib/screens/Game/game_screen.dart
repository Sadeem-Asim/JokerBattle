import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 207, 149),
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover)),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        horizontal: 15, vertical: 10),
                  ),
                  child: const Text('Rules',
                      style: TextStyle(
                          fontFamily: "BreatheFire",
                          fontSize: 25,
                          color: Colors.white)),
                ),
                SizedBox(width: 7),
                const SizedBox(width: 17),
                ElevatedButton(
                  onPressed: () {
                    _onButtonPressed(2);
                    // Navigator.pushNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedButtonIndex == 2
                        ? Color(0xFF9B9DAD)
                        : Color.fromARGB(255, 210, 220, 255),
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/backbutton.svg',
                    fit: BoxFit.cover,
                    // width: 49,
                  ),
                ),
                // const SizedBox(width: 15),
              ]),

              const SizedBox(height: 45),

              Container(
                padding: EdgeInsets.all(170),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF39036),
                      Color(0xFFE7762A),
                      Color(0xFFDD6221)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

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
                child: const Text("null"),
              ),







              Container(
                padding: EdgeInsets.fromLTRB(3, 25,7, 25),
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

                  ElevatedButton(
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
                          horizontal: 8, vertical: 8),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/backbutton.svg',
                      fit: BoxFit.cover,
                      // width: 49,
                    ),
                    // ),
                  ),


                  ElevatedButton(
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
                          horizontal: 8, vertical: 8),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/backbutton.svg',
                      fit: BoxFit.cover,
                      // width: 49,
                    ),
                    // ),
                  ),



                  ElevatedButton(
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
                          horizontal: 8, vertical: 8),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/backbutton.svg',
                      fit: BoxFit.cover,
                      // width: 49,
                    ),
                    // ),
                  ),

                  ElevatedButton(
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
                          horizontal: 8, vertical: 8),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/backbutton.svg',
                      fit: BoxFit.cover,
                      // width: 49,
                    ),
                    // ),
                  ),





                ],
              ))

              // )
            ],
          ),
        ));
  }
}
