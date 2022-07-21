import 'package:buzzword/word_details_screen.dart';
import 'package:flutter/material.dart';

Widget generateWordCard(var word, List favourites, BuildContext context, var userId, Function setHomeState, List filteredFavouriteWords){
  bool isFavourite = favourites.contains(word['_id']);
  var cardColor = isFavourite? Colors.amberAccent : Colors.white;
  return Card(
    color: cardColor,
    child: InkWell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${word['word']}", style: const TextStyle(fontWeight: FontWeight.bold),),
            Text("${word['type']}",style: const TextStyle(fontStyle: FontStyle.italic),)
          ],
        ),
      ),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => WordDetails(word: word, favourites: favourites, userId: userId,)));

        if(favourites.contains(word['_id']) && !filteredFavouriteWords.contains(word)){
          filteredFavouriteWords.add(word);
        }
        if(!favourites.contains(word['_id']) && filteredFavouriteWords.contains(word)){
          filteredFavouriteWords.remove(word);
        }

        setHomeState();
      },
    ),
  );
}