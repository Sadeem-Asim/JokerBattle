import 'package:flutter/material.dart';

class FlippableCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlippableCard({
    required this.front,
    required this.back,
    Key? key,
  }) : super(key: key);

  @override
  _FlippableCardState createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard> {
  bool isFlipped = false; 


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFlipped = !isFlipped;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 
 500),
        child: isFlipped ? widget.back : widget.front,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}