import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'loading_screen.dart';

const createUserURI = 'https://api-buzzword.herokuapp.com/createUser';
const loginUserURI = 'https://api-buzzword.herokuapp.com/loginUser';

Future<http.Response> createUser(String username, String password) async {
  return await http.post(
    Uri.parse(createUserURI),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username':username,
      'password':password
    }),
  );
}

Future<http.Response> loginUser(String username, String password) async {
  return await http.post(
    Uri.parse(loginUserURI),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username':username,
      'password':password
    }),
  );
}

bool isValidStringInput(String text){
  for(int i=0;i<text.length;i++){
    if(!((('a'.codeUnitAt(0)< text[i].toLowerCase().codeUnitAt(0)) && (text[i].toLowerCase().codeUnitAt(0)<'z'.codeUnitAt(0)))||(('0'.codeUnitAt(0)< text[i].codeUnitAt(0)) && (text[i].codeUnitAt(0)<'9'.codeUnitAt(0)))||(text[i]=='_'))){
      return false;
    }
  }
  return true;
}

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  var appBarTitle = "Log In to Continue";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      body: const Center(child: LogInForm()),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var appBarTitle = "Sign Up To Continue";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      body: const Center(child: SignUpForm()),
    );
  }
}


class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double heightScale = (MediaQuery.of(context).size.height / 843);
    double widthScale = (MediaQuery.of(context).size.width / 411);
    return Form(
      key : _formKey,
      child: SingleChildScrollView(
        child: Column(
          children:<Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0*widthScale),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: "Enter Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorMaxLines: 2
                ),
                maxLength: 15,
                validator: (value){
                  if (value!.isEmpty){
                    return "Please Enter Username";
                  }
                  if (!isValidStringInput(value)){
                    return "Username can only contain underscores and alphanumeric characters";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10*heightScale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0*widthScale),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorMaxLines: 2
                ),
                validator: (value){
                  if (value!.isEmpty){
                    return "Please Enter a Password";
                  }
                  if (!isValidStringInput(value)){
                    return "Password can only contain underscores and alphanumeric characters";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10*heightScale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0*widthScale),
              child: TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Re-Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorMaxLines: 2
                ),
                validator: (value){
                  if (value!.isEmpty){
                    return "Please Re-Enter your Password";
                  }
                  if (value != passwordController.text){
                    return "Please re-enter the same password as entered above";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 30*heightScale,
            ),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),foregroundColor: MaterialStateProperty.all<Color>(Colors.black)),
              onPressed: () async {
                if(_formKey.currentState!.validate()){
                  //Starting the loading screen,
                  Navigator.of(context).push(
                      PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) {
                            return const LoadingScreen();
                          }
                      ));

                  final response = await createUser(nameController.text, passwordController.text);
                  final responseBody = jsonDecode(response.body);
                  print(responseBody);
                  //Stopping the loading screen,
                  Navigator.pop(context);

                  if(responseBody['userCreated']){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LogInScreen()));
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: const Text("User Created"),
                            content: const Text("A user with the given credentials has been created. Please login to proceed."),
                            actions: [
                              TextButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK")
                              )
                            ],
                          );
                        }
                    );
                  }
                  else{
                    if(responseBody['userAlreadyExists']){
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text("Username Taken"),
                              content: const Text("A user with this username already exists. Please choose another username."),
                              actions: [
                                TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    }, 
                                    child: const Text("OK")
                                )
                              ],
                            );
                          }
                      );
                    }
                    else{
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text("Unknown Error"),
                              content: const Text("An unknown error has occurred. Please try again after some time."),
                              actions: [
                                TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK")
                                )
                              ],
                            );
                          }
                      );
                    }
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0*heightScale, horizontal: 30.0*widthScale),
                child: const Text("Sign Up"),
              ),
            ),
            SizedBox(
              height: 20.0*heightScale,
            ),
            GestureDetector(
              child: const Text("Already have an account?",style: TextStyle(decoration: TextDecoration.underline, color: Colors.indigo)),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LogInScreen()));
              },
            )

          ],
        ),
      ),
    );
  }

  @override
  void dispose(){
    super.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
  }
}

class LogInForm extends StatefulWidget {
  const LogInForm({Key? key}) : super(key: key);

  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double heightScale = (MediaQuery.of(context).size.height / 843);
    double widthScale = (MediaQuery.of(context).size.width / 411);
    return Form(
      key : _formKey,
      child: SingleChildScrollView(
        child: Column(
          children:<Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0*widthScale),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: "Enter Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )
                ),
                validator: (value){
                  if (value!.isEmpty){
                    return "Please enter your registered Username";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10*heightScale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0*widthScale),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )
                ),
                validator: (value){
                  if (value!.isEmpty){
                    return "Please enter your Password";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 30*heightScale,
            ),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),foregroundColor: MaterialStateProperty.all<Color>(Colors.black)),
              onPressed: () async {
                if(_formKey.currentState!.validate()){
                  //Starting the loading screen
                  Navigator.of(context).push(
                      PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) {
                            return const LoadingScreen();
                          }
                      ));

                  final response = await loginUser(nameController.text, passwordController.text);
                  final responseBody = jsonDecode(response.body);
                  print(responseBody);
                  //Stopping the loading screen
                  Navigator.pop(context);

                  if(responseBody['loggedInSuccessfully']){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(username: responseBody['username'], id: responseBody['_id'], favourites: responseBody['favourites'], words: responseBody['words'], wordOfTheDay: responseBody['wordOfTheDay'],)));
                    nameController.clear();
                    passwordController.clear();
                  }
                  else{
                    if(responseBody['noSuchUser']){
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text("No Such User"),
                              content: const Text("There is no user with this username. Please enter a valid username."),
                              actions: [
                                TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK")
                                )
                              ],
                            );
                          }
                      );
                    }
                    else if(responseBody['incorrectPassword']){
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text("Incorrect Password"),
                              content: const Text("The password entered does not match that of the user. Please enter the correct password."),
                              actions: [
                                TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK")
                                )
                              ],
                            );
                          }
                      );
                    }
                    else{
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text("Unknown Error"),
                              content: const Text("An unknown error has occurred. Please try again after some time."),
                              actions: [
                                TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK")
                                )
                              ],
                            );
                          }
                      );
                    }
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0*heightScale, horizontal: 30.0*widthScale),
                child: const Text("Login"),
              ),
            ),
            SizedBox(
              height: 20.0*heightScale,
            ),
            GestureDetector(
              child: const Text("Not a member",style: TextStyle(decoration: TextDecoration.underline, color: Colors.indigo)),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SignUpScreen()));
              },
            )
          ],
        ),
      ),
    );
  }
}
