import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoScreen extends StatefulWidget {
  static const String routeName = '/info';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => InfoScreen(),
    );
  }

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
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
      content = const RulesContent();
    } else if (_selectedButtonIndex == 1) {
      content = const ComboContent();
    } else if (_selectedButtonIndex == 2) {
      content = const PlayContent();
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
          child: Column(
            children: [
              Row(children: [
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
                const SizedBox(width: 36),
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
                ElevatedButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/');
                    _onButtonPressed(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedButtonIndex == 1
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
                  child: const Text('Combo',
                      style: TextStyle(
                          fontFamily: "BreatheFire",
                          fontSize: 25,
                          color: Colors.white)),
                ),
                const SizedBox(width: 8),
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
                  child: const Text('Play',
                      style: TextStyle(
                          fontFamily: "BreatheFire",
                          fontSize: 25,
                          color: Colors.white)),
                ),
                const SizedBox(width: 3),
              ]),
              const SizedBox(height: 30),

              Expanded(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFF5C5E68),
                    border: Border.all(
                      color: Color(0xFF616374), // Set the border color
                      width: 4,
                      // Set the border width
                    ),
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/Vector.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: content,
                ),
              ),
              // )
            ],
          ),
        ));
  }
}

class PlayContent extends StatelessWidget {
  const PlayContent({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/Game4.png'),
        const SizedBox(
          height: 5,
        ),
        Image.asset('assets/images/Game5.png'),
        const SizedBox(
          height: 5,
        ),
        Image.asset('assets/images/Game1.png'),
        const SizedBox(
          height: 5,
        ),
        const SizedBox(
          height: 2,
        ),
        Expanded(
            child: Container(
          child: Text(
              "1.Opponent's cards. They will be visible to you after you lay out the combination.\n2. The field where you will lay out your combination.\n3. Your cards. You can choose 1 or more of them to perform an action with.\n4. The sum of the players' scores. \n5. Info button. \n6. This is information about your deck, where the first number shows the discarded cards and the second number shows the remaining cards in the deck.\n7. A button that opens a menu with your jokers.\n8. Place the selected cards on the field.\n9. Reset and replace the selected cards.\n10. Current level.\n11. Current round.",
              style: TextStyle(
                  fontFamily: "BreatheFire",
                  fontSize: 11.3,
                  color: Colors.white)),
        ))
      ],
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }
}

class ComboContent extends StatelessWidget {
  const ComboContent({super.key});

  // Assuming this is the data structure you'll pass to the widget
  final List<Map<String, dynamic>> data = const [
    {
      "images": [
        "assets/images/card_hearts_10.png",
        "assets/images/card_spades_02.png",
        "assets/images/card_spades_03.png",
      ],
      "text": "High Card X1"
    },
    {
      "images": [
        "assets/images/card_diamonds_K.png",
        "assets/images/card_spades_K.png"
      ],
      "text": "Pair +S scores"
    },
    {
      "images": [
        "assets/images/card_joker_black.png",
        "assets/images/card_joker_red.png",
        "assets/images/card_diamonds_Q.png",
        "assets/images/card_hearts_Q.png",
      ],
      "text": "Two Pair +10 scores"
    },
    {
      "images": [
        "assets/images/card_spades_10.png",
        "assets/images/card_hearts_10.png",
        "assets/images/card_diamonds_10.png",
      ],
      "text": "Three of a kind x2"
    },
    {
      "images": [
        "assets/images/card_spades_02.png",
        "assets/images/card_spades_03.png",
        "assets/images/card_spades_04.png",
        "assets/images/card_spades_05.png",
        "assets/images/card_spades_06.png",
      ],
      "text": "Straight x2"
    },
    {
      "images": [
        "assets/images/card_spades_07.png",
        "assets/images/card_spades_10.png",
        "assets/images/card_hearts_Q.png",
        "assets/images/card_spades_04.png",
        "assets/images/card_spades_K.png",
      ],
      "text": "Flush x3"
    },
    {
      "images": [
        "assets/images/card_spades_A.png",
        "assets/images/card_hearts_A.png",
        "assets/images/card_diamonds_K.png",
        "assets/images/card_hearts_K.png",
        "assets/images/card_spades_K.png",
      ],
      "text": "Full house x4"
    },
    {
      "images": [
        "assets/images/card_clubs_A.png",
        "assets/images/card_spades_A.png",
        "assets/images/card_hearts_A.png",
        "assets/images/card_diamonds_A.png",
      ],
      "text": "Four of a kind xS"
    },
    {
      "images": [
        "assets/images/card_spades_10.png",
        "assets/images/card_spades_J.png",
        "assets/images/card_spades_K.png",
        "assets/images/card_spades_Q.png",
        "assets/images/card_clubs_A.png",
      ],
      "text": "Straight flush x7"
    },
    // Add more entries if needed
  ];

  final List<Map<String, String>> data2 = const [
    {
      "image": "assets/images/card_spades_10.png",
      "text": "Suit- changes the suit of\nany card in your hand",
    },
    {
      "image": "assets/images/card_spades_10.png",
      "text":
          "Fake- make any card in your hand a\ncopy of another card in your hand",
    },
    {
      "image": "assets/images/card_spades_10.png",
      "text":
          "Extra change-gives you an extra attempt\nto change the cards in your hand",
    },
    {
      "image": "assets/images/card_spades_10.png",
      "text":
          "Trump- changes a card from your hand to\na specific card in the rest of the deck",
    },
    {
      "image": "assets/images/card_spades_10.png",
      "text":
          "Empty bonus- adds to the result of your\ncombo the amount of points for cards\nthat were not in your combo.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // First part: 50/50 layout with multiple images
      Expanded(
          child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                flex: 9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: data[index]['images'].map<Widget>((image) {
                    return Image.asset(
                      image,
                      width: 42,
                      height: 42,
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                flex: 5,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data[index]['text'],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: "BreatheFire",
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      )),

      Column(
        children: data2.map<Widget>((item) {
          return Padding(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    item['image']!,
                    width: 42,
                    height: 46,
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Text(
                    item['text']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: "BreatheFire",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      )
    ]);
  }
}

class RulesContent extends StatelessWidget {
  const RulesContent({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text(
        "This is a 'roguelike' game in which you will fight with your opponent for the sum of points in poker combinations. With each victory you will get chips, for which you can upgrade your deck of cards, and after defeat you lose all the upgrades, start the game again, but save chips.\n To pass a level, you need to score more points than your opponent.\n Each level consists of 5 rounds, where you will need to make a combination of 5 cards in the center of the game table, which you choose from those that in your hand. You are obliged to put on the table at least 5 cards that will leave the deck after the current round.\n Your opponent will only have 5 cards, which he gets from a separate 52-card deck. Unlike you, your opponent always gets points for each card in his combo + bonuses for combinations. You will only see your opponent's combination after you have made your own.\n  You will have 7 cards in your hand, among which you have to choose 5 cards for the combination, but you will get points only for those cards that were directly involved in the combination + combination bonus. For example, if you have a 'Pair' combination, you will get a bonus for the pair and for each card in the pair. Each round, you will get new cards from the remaining cards in your deck. During each level, you may exchange any number of cards from your hand for new cards from the deck up to 3 times. But discarded cards will not return to the deck until the next level. If you want to use a joker, do so before laying down a combination. Each card in the combination brings a certain number of points, in addition to the bonuses of the combination. Points on cards with numbers correspond to values. And here are the points for cards with letters: J=11; Q=12; K=13, A=14. For winning a level, you'll get chips that you can upgrade your deck with: add double cards and joker cards.  Double cards increase the number of cards in your deck and increase the probability of combinations. You can only add each doublet card 1 time. Jokers can give you new possibilities in the game. But purchased jokers will go from round to round until they are spent or until you lose. Each joker can only be added in one copy. You can only add the same joker again after you have spent it. You can have as few as 5 jokers in a game.",
        style: TextStyle(
            fontFamily: "BreatheFire", fontSize: 15, color: Colors.white));
  }
}
