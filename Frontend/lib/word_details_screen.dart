import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'loading_screen.dart';

const addFavouriteURI = 'https://api-buzzword.herokuapp.com/addFavourite';
const removeFavouriteURI = 'https://api-buzzword.herokuapp.com/removeFavourite';

Future<http.Response> addFavourite(String userId, String wordId) async {
  return await http.post(
    Uri.parse(addFavouriteURI),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'userId':userId,
      'wordId':wordId
    }),
  );
}

Future<http.Response> removeFavourite(String userId, String wordId) async {
  return await http.post(
    Uri.parse(removeFavouriteURI),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'userId':userId,
      'wordId':wordId
    }),
  );
}

class WordDetails extends StatefulWidget {
  const WordDetails({Key? key, required this.word, required this.favourites, required this.userId}) : super(key: key);
  final word;
  final List favourites;
  final userId;

  @override
  State<WordDetails> createState() => _WordDetailsState();
}

class _WordDetailsState extends State<WordDetails> {
  @override
  Widget build(BuildContext context) {
    bool isFavourite = widget.favourites.contains(widget.word['_id']);
    Icon heartIcon = isFavourite? const Icon(Icons.favorite, color: Colors.redAccent, size: 35,) : const Icon(Icons.favorite_border, color: Colors.black, size: 35,);
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: const Text("Buzzword"),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                  flex: 5,
                  child: Container(color: Colors.transparent,)
              ),
              Expanded(
                flex: 10,
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${widget.word['word']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                              IconButton(
                                  onPressed: () async {

                                    Navigator.of(context).push(
                                        PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (BuildContext context, _, __) {
                                              return const LoadingScreen();
                                            }
                                    ));

                                    if(!isFavourite){
                                      final response = await addFavourite(widget.userId, widget.word['_id']);
                                      final responseBody = jsonDecode(response.body);
                                      print(responseBody);
                                      setState((){
                                        widget.favourites.add(widget.word['_id']);
                                      });
                                    }
                                    else{
                                      final response = await removeFavourite(widget.userId, widget.word['_id']);
                                      final responseBody = jsonDecode(response.body);
                                      print(responseBody);
                                      setState((){
                                        widget.favourites.remove(widget.word['_id']);
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  icon: heartIcon,
                              )
                            ],
                          ),
                        ),
                        Expanded(flex: 3,child: Text("${widget.word['type']}", style: const TextStyle(fontStyle: FontStyle.italic,fontSize: 20),)),
                        Expanded(flex: 5,child: SingleChildScrollView(child: Text("${widget.word['meaning']}",style: const TextStyle(fontSize: 15),))),
                        const Expanded(flex: 3,child: Text("Usage :- ",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)),
                        Expanded(flex: 3,child: SingleChildScrollView(child: Text("${widget.word['usage']}",style: const TextStyle(fontSize: 15),))),
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
        ),
    );
  }
}
