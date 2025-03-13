import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class CardModel {
  String front;
  String back;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.front,
    required this.back,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData.dark(),
      home: const CardMatchingGame(),
    );
  }
}

class CardMatchingGame extends StatefulWidget {
  const CardMatchingGame({super.key});

  @override
  _CardMatchingGameState createState() => _CardMatchingGameState();
}

class _CardMatchingGameState extends State<CardMatchingGame> {
  late List<CardModel> cards;
  late List<int> selectedCards;
  late bool isBusy;
  int score = 0;
  final int gridSize = 4;

  @override
  void initState() {
    super.initState();
    initializeGame();
    selectedCards = [];
    isBusy = false;
  }

  void initializeGame() {
    List<String> icons = ['🚗', '🚕', '🚌', '🚓', '🚑', '🚒', '🚜', '🚛'];
    cards = [];
    for (int i = 0; i < icons.length; i++) {
      cards.add(CardModel(front: icons[i], back: '❓'));
      cards.add(CardModel(front: icons[i], back: '❓'));
    }
    cards.shuffle();
  }

  Future<void> flipCard(int index) async {
    if (isBusy || cards[index].isFaceUp || cards[index].isMatched) return;

    setState(() {
      cards[index].isFaceUp = true;
    });

    selectedCards.add(index);

    if (selectedCards.length == 2) {
      isBusy = true;
      await Future.delayed(const Duration(seconds: 1));
      if (cards[selectedCards[0]].front != cards[selectedCards[1]].front) {
        setState(() {
          cards[selectedCards[0]].isFaceUp = false;
          cards[selectedCards[1]].isFaceUp = false;
          score -= 5;
        });
      } else {
        setState(() {
          cards[selectedCards[0]].isMatched = true;
          cards[selectedCards[1]].isMatched = true;
          score += 10;
        });
      }
      selectedCards.clear();
      isBusy = false;
    }
  }
}
