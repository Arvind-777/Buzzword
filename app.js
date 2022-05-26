const express = require('express');
const mongoose = require('mongoose');
const User = require('./models/user');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');

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
            res.send("User with that username already exists!");
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
                    res.send("User has been created");
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
            res.send("No such user exists!");
        }
        else{
            user = result[0];
            bcrypt.compare(password, user.password, (err, result)=>{
                if(err){
                    console.log(err);
                }
                else if(result){
                    res.json(user);
                }
                else{
                    res.send("The password does not match that of the user");
                }
            });
        }
    }).catch(err=>{
        console.log(err);
    });
});

app.use((req, res)=>{
    res.status(404).send("404 Not Found :(")
});