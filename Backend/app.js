const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');
const schedule = require('node-schedule');

const User = require('./models/user');
const Word = require('./models/word');
const WordOfTheDay = require('./models/wordOfTheDay');

const app = express();
const port = process.env.PORT || 3000;

const dbURI = "mongodb+srv://Arvind:abcd1234@cluster0.iezod.mongodb.net/buzzword?retryWrites=true&w=majority";

mongoose.connect(dbURI).then(result=>{
    app.listen(port, ()=>{console.log("listening on port "+port)});
}).catch(err=>{
    console.log(err);
});

// app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());

const wordOfTheDayResetRule = new schedule.RecurrenceRule();
wordOfTheDayResetRule.tz = 'Asia/Calcutta';
wordOfTheDayResetRule.hour = 0;
wordOfTheDayResetRule.minute = 0;
const wordOfTheDayReset = schedule.scheduleJob(wordOfTheDayResetRule, function(){
    console.log("Scheduled Function called");
    var wordOfTheDay;
    var possibleWordOfTheDays = [];
    WordOfTheDay.find().then(result=>{
        wordOfTheDay = result[0];
        // console.log("1-",wordOfTheDay);
        Word.find().then(result=>{
            var allWords = [];
            for(var i=0;i<result.length;i++){
                allWords.push(result[i]._id);
            }
            // console.log("2-",allWords);
            wordOfTheDay.allWords = allWords;
            wordOfTheDay.previousWordOfTheDays.push(wordOfTheDay.wordOfTheDayId);
            // console.log("3-",wordOfTheDay.previousWordOfTheDays);
            possibleWordOfTheDays = allWords.filter(function(itm){
                return (wordOfTheDay.previousWordOfTheDays.indexOf(itm) == -1);
            });
            // console.log("4-", possibleWordOfTheDays);
            wordOfTheDay.wordOfTheDayId = possibleWordOfTheDays[Math.floor(Math.random()*possibleWordOfTheDays.length)];
            // console.log("5-", wordOfTheDay.wordOfTheDayId);
            Word.findById(wordOfTheDay.wordOfTheDayId).then(result=>{
                // console.log("6-", result);
                wordOfTheDay.wordOfTheDay = result;
                wordOfTheDay.save();
            }).catch(err=>{
                console.log(err);
            });
        }).catch(err=>{
            console.log(err);
        })
    }).catch(err=>{
        console.log(err);
    })
});

app.get('/',(req, res)=>{
    User.find().then(result=>{
        res.send(result);
    }).catch(err=>{
        console.log(err);
    })
});

app.post('/createUser',(req, res)=>{
    var username = req.body.username;
    var password =req.body.password;
    var userAlreadyExists;

    User.find({username:username}).then(result=>{
        userAlreadyExists = (result.length>=1);
        if(userAlreadyExists){
            res.json({
                userCreated: false,
                userAlreadyExists: true,
                username: username,
                _id: null
            });
        }
        else{
            bcrypt.hash(password, 10, (err, hash)=>{
                if(err){
                    return console.log("Password encryption error during user creation");
                }
                const user = new User({
                    username: username,
                    password: hash
                });
        
                user.save().then(result=>{
                    res.json({
                        userCreated: true,
                        userAlreadyExists: false,
                        username: result.username,
                        _id: result._id
                    });
                }).catch(err=>{
                    console.log(err);
                });
            });
        }
    }).catch(err=>{
        console.log(err);
    });
});

app.post('/loginUser',(req, res)=>{
    var username = req.body.username;
    var password = req.body.password;
    var userDoesntExist;
    var user;

    User.find({username:username}).then(result=>{
        userDoesntExist = (result.length===0);
        if(userDoesntExist){
            res.json({
                loggedInSuccessfully: false,
                noSuchUser: true,
                incorrectPassword: false,
                username: username,
                _id: null,
                favourites: null,
                words: null
            });
        }
        else{
            user = result[0];
            bcrypt.compare(password, user.password, (err, result)=>{
                if(err){
                    console.log(err);
                    res.json({
                        loggedInSuccessfully: false,
                        noSuchUser: false,
                        incorrectPassword: false,
                        username: username,
                        _id: null,
                        favourites: null,
                        words: null
                    });
                }
                else if(result){
                    Word.find().then(allWords=>{
                        WordOfTheDay.find().then(result=>{
                            var wordOfTheDay = result[0];
                            res.json({
                                loggedInSuccessfully: true,
                                noSuchUser: false,
                                incorrectPassword: false,
                                username: user.username,
                                _id: user._id,
                                favourites: user.favourites,
                                words: allWords,
                                wordOfTheDay: wordOfTheDay.wordOfTheDay
                            });
                        }).catch(err=>{
                            console.log(err);
                        });
                    }).catch(err=>{
                        console.log(err);
                    });
                }
                else{
                    res.json({
                        loggedInSuccessfully: false,
                        noSuchUser: false,
                        incorrectPassword: true,
                        username: username,
                        _id: null,
                        favourites: null,
                        words: null
                    });
                }
            });
        }
    }).catch(err=>{
        console.log(err);
    });
});

app.post('/addFavourite', (req, res)=>{
    var userId = req.body.userId;
    var wordId = req.body.wordId;
    
    User.findById(userId, (err, user)=>{
        if(err){
            console.log(err);
        }
        else{
            var favourites = user.favourites;
            if(!favourites.includes(wordId)){
                favourites.push(wordId);
                user.favourites = favourites;
                user.save().then(result=>{
                    res.json({
                        favourites: result.favourites
                    });
                });
            }
        }
    })
});

app.post('/removeFavourite', (req, res)=>{
    var userId = req.body.userId;
    var wordId = req.body.wordId;
    
    User.findById(userId, (err, user)=>{
        if(err){
            console.log(err);
        }
        else{
            var favourites = user.favourites;
            if(favourites.includes(wordId)){
                const index = favourites.indexOf(wordId);
                favourites.splice(index, 1);
                user.favourites = favourites;
                user.save().then(result=>{
                    res.json({
                        favourites: result.favourites
                    });
                });
            }
        }
    })
});

app.use((req, res)=>{
    res.status(404).send("404 Not Found :(")
});
