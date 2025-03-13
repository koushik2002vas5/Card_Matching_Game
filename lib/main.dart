import 'package:flutter/material.dart';
import 'dart:async';

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
      theme: ThemeData.dark(), // Dark theme
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
  late Timer timer;
  int score = 0;
  int timeElapsed = 0;

  final int gridSize = 4;

  @override
  void initState() {
    super.initState();
    initializeGame();
    startTimer();
  }

  void initializeGame() {
    List<String> icons = [
      '🚗',
      '🚕',
      '🚌',
      '🚓',
      '🚑',
      '🚒',
      '🚜',
      '🚛',
      '🚎',
      '🚚',
      '🏎️',
      '🚀'
    ];
    int totalPairs = (gridSize * gridSize) ~/ 2;
    if (icons.length < totalPairs) {
      throw Exception('Not enough icons to populate the grid.');
    }
    cards = [];
    for (int i = 0; i < totalPairs; i++) {
      cards.add(CardModel(front: icons[i], back: '❓'));
      cards.add(CardModel(front: icons[i], back: '❓'));
    }
    cards.shuffle();
    selectedCards = [];
    isBusy = false;
  }

  void startTimer() {
    timeElapsed = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        timeElapsed++;
      });
    });
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

    if (cards.every((card) => card.isMatched)) {
      timer.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: Text(
                'You won the game in $timeElapsed seconds with a score of $score!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          );
        },
      );
    }
  }

  void resetGame() {
    setState(() {
      initializeGame();
      startTimer();
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Card Matching Game'),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score',
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                Text('Time: $timeElapsed s',
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => flipCard(index),
                  child: Card(
                    color: cards[index].isFaceUp || cards[index].isMatched
                        ? Colors.grey[800]
                        : Colors.grey[900],
                    child: Center(
                      child: Text(
                        cards[index].isFaceUp
                            ? cards[index].front
                            : cards[index].back,
                        style: const TextStyle(
                            fontSize: 30.0, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
