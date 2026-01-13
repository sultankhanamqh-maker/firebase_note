// ignore_for_file: must_be_immutable



import 'package:fire_note/app_constants.dart';
import 'package:fire_note/home_page.dart';
import 'package:fire_note/signup_page.dart';
import 'package:fire_note/ui_helper/ui_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {

  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passwordVisible = false;

  bool isLoading = false;

  bool isLogin = false;

  var emailController = TextEditingController();

  var passController = TextEditingController();

  FirebaseAuth? auth;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome' back "),
              SizedBox(height: 11),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  final bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value ?? "");
                  if (value == null || value.isEmpty) {
                    return "Please Enter your email";
                  }
                  if (!emailValid) {
                    return "Please Enter valid Email";
                  }
                  return null;
                },
                decoration: myDecor(hint: "Enter Your Email", label: "Email"),
              ),
              SizedBox(height: 11),
              StatefulBuilder(
                builder: (context, ss) {
                  return TextFormField(
                    controller: passController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter your Password";
                      }
                      return null;
                    },
                    obscureText: !passwordVisible,
                    decoration: myDecor(
                      hint: "Enter your Password",
                      label: "Password",
                      isPassword: true,
                      passWordVisible: passwordVisible,
                      onTap: () {
                        passwordVisible = !passwordVisible;
                        ss(() {});
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 11),
              ElevatedButton(onPressed: ()async{
                if(formKey.currentState!.validate()){
                  try{
                    UserCredential userCred = await auth!.signInWithEmailAndPassword(email: emailController.text, password: passController.text);
                    if(userCred.user != null){
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString(AppConstants.loginId, userCred.user!.uid);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are Logged in Successfully")));
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something Went Wrong")));
                    }
                  }
                  on FirebaseAuthException catch(e){
                    if(e.code == "user-not-found"){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                  catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }

                }
              }, child: Text("Login")),
              SizedBox(height: 11),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already Have an Account ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "Create an account",
                        style: TextStyle(color: Colors.amber),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
