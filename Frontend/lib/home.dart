import 'package:buzzword/wordOfTheDay_screen.dart';
import 'package:buzzword/word_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.username, required this.id, required this.favourites, required this.words, required this.wordOfTheDay}) : super(key: key);
  final String username;
  final String id;
  final List favourites; //favourites is a list containing id's of the favourite word objects
  final List words; //words is a list of all the word objects
  final wordOfTheDay;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget appBarTitle = const Text("Buzzword");
  Icon searchIcon = const Icon(Icons.search);
  TextEditingController filter = TextEditingController();
  List favouriteWords = [];
  List filteredWords = [];
  List filteredFavouriteWords = [];

  @override
  void initState() {
    super.initState();
    filteredWords = widget.words;

    for (var word in widget.words) {
      if(widget.favourites.contains(word['_id'])){
        favouriteWords.add(word);
      }
    }
    filteredFavouriteWords = favouriteWords;

    filter.addListener(() {
      if(filter.text.isEmpty){
        setState((){
          filteredWords = widget.words;
          filteredFavouriteWords = favouriteWords;
        });
      }
      else{
        setState((){
          filteredWords = [];
          filteredFavouriteWords = [];
          for(int i=0;i<widget.words.length;i++){
            if(widget.words[i]['word'].toLowerCase().contains(filter.text.toLowerCase())){
              filteredWords.add(widget.words[i]);
            }
          }
          for(int i=0;i<favouriteWords.length;i++){
            if(favouriteWords[i]['word'].toLowerCase().contains(filter.text.toLowerCase())){
              filteredFavouriteWords.add(favouriteWords[i]);
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    favouriteWords = [];
    for (var word in widget.words) {
      if(widget.favourites.contains(word['_id'])){
        favouriteWords.add(word);
      }
    }
    if(searchIcon.icon == Icons.search){filteredFavouriteWords = favouriteWords;}

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: appBarTitle,
          bottom: const TabBar(
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.redAccent,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "All Words", icon: Icon(Icons.library_books),),
              Tab(text: "Favourites", icon: Icon(Icons.favorite),),
              Tab(text: "WordOfTheDay", icon: Icon(CupertinoIcons.calendar_today),)
            ],
          ),
          actions: [
            IconButton(
              icon: searchIcon,
              onPressed: (){
                  if(searchIcon.icon == Icons.search){
                    setState((){
                      searchIcon = const Icon(Icons.close);
                      appBarTitle = TextField(
                        controller: filter,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search...",
                        ),
                      );
                    });
                  }
                  else{
                    setState((){
                      filter.clear();
                      searchIcon = const Icon(Icons.search);
                      appBarTitle = const Text("Buzzword");
                      filteredWords = widget.words;
                    });
                  }
              },
            ),
          ],
        ),
        body: WillPopScope(
          onWillPop: () {
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    title: const Text("Exit Buzzword"),
                    content: const Text("Do you want to exit Buzzword?"),
                    actions: [
                      TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: const Text("No")
                      ),
                      TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                            SystemNavigator.pop();
                          },
                          child: const Text("Yes")
                      )
                    ],
                  );
                }
            );
            return Future.value(false);
          },
          child: TabBarView(
            children: [
              ListView.builder(
                itemCount: filteredWords.length,
                itemBuilder: (context, position){
                  return generateWordCard(filteredWords[position], widget.favourites, context, widget.id, passableSetState, filteredFavouriteWords);
                }
                ),
              ListView.builder(
                itemCount: filteredFavouriteWords.length,
                itemBuilder: (context, position){
                  return generateWordCard(filteredFavouriteWords[position], widget.favourites, context, widget.id, passableSetState, filteredFavouriteWords);
                },
              ),
              WordOfTheDay(wordOfTheDay: widget.wordOfTheDay)
            ]
          ),
        )
      ),
    );
  }

  void passableSetState(){
    setState((){});
  }
}
