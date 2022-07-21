import 'package:flutter/material.dart';

class WordOfTheDay extends StatefulWidget {
  const WordOfTheDay({Key? key, required this.wordOfTheDay}) : super(key: key);
  final wordOfTheDay;

  @override
  State<WordOfTheDay> createState() => _WordOfTheDayState();
}

class _WordOfTheDayState extends State<WordOfTheDay> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: [
            Expanded(
                flex: 5,
                child: Container(color: Colors.transparent,)
            ),
            Expanded(
              flex: 10,
              child: Card(
                color: Colors.greenAccent,
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text("${widget.wordOfTheDay['word']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                      ),
                      Expanded(flex: 5,child: Text("${widget.wordOfTheDay['type']}", style: const TextStyle(fontStyle: FontStyle.italic,fontSize: 20),)),
                      Expanded(flex: 5,child: SingleChildScrollView(child: Text("${widget.wordOfTheDay['meaning']}",style: const TextStyle(fontSize: 15),))),
                      const Expanded(flex: 3,child: Text("Usage :- ",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)),
                      Expanded(flex: 3,child: SingleChildScrollView(child: Text("${widget.wordOfTheDay['usage']}",style: const TextStyle(fontSize: 15),))),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 5,
                child: Container(color: Colors.transparent,)
            ),
          ],
        ),
      );
  }
}