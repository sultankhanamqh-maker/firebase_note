

// ignore: must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_note/ui_helper/ui_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class SignUpPage extends StatefulWidget {

  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool passWordVisible = false;

  bool confirmPassWordVisible = false;

  bool isLoading = false;

  bool isSignUpBuilder = false;

  FirebaseAuth? auth;

  TextEditingController nameController = TextEditingController();

  TextEditingController mobileController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passController = TextEditingController();

  TextEditingController confirmPassController = TextEditingController();

  FirebaseFirestore? firebaseFirestore;
  CollectionReference? userRef;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    firebaseFirestore = FirebaseFirestore.instance;
    userRef = firebaseFirestore!.collection("users");
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
              Text("Create an Acount"),
              SizedBox(height: 11),
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please Enter your Name";
                  }
                  if (value.length < 3) {
                    return "Please Enter valid Name";
                  }
                  return null;
                },
                decoration: myDecor(hint: "Enter your Name", label: "Name"),
              ),
              SizedBox(height: 11),
              TextFormField(

                controller: emailController,
                validator: (value) {
                  final bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value ?? "");
                  if (value == null || value.isEmpty) {
                    return "Please Enter your Email";
                  }
                  if (!emailValid) {
                    return "Please Enter a valid Email";
                  }
                  return null;
                },
                decoration: myDecor(hint: "Enter your Email", label: "Email"),
              ),
              SizedBox(height: 11),
              TextFormField(
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return "Please Enter your Name";
                  }
                  if(value.length < 10){
                    return "Please enter a valid number";
                  }
                  return null;
                },
                controller: mobileController,
                decoration: myDecor(
                  hint: "Enter your Mobile No",
                  label: "Mobile No",
                ),
              ),
              SizedBox(height: 11),

              StatefulBuilder(
                builder: (context, ss) {
                  return TextFormField(
                    controller: passController,
                    validator: (value) {
                      final bool passValid = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                      ).hasMatch(value ?? "");
                      if (value == null || value.isEmpty) {
                        return "Please Enter  Password";
                      }
                      if (!passValid) {
                        return "Please Enter valid Password";
                      }
                      return null;
                    },
                    obscureText: !passWordVisible,
                    decoration: myDecor(
                      hint: "Enter your Password ",
                      label: "Password",
                      isPassword: true,
                      passWordVisible: passWordVisible,
                      onTap: () {
                        passWordVisible = !passWordVisible;
                        ss(() {});
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 11),
              StatefulBuilder(
                builder: (context, ss) {
                  return TextFormField(
                    controller: confirmPassController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Re_type Your Password";
                      }
                      if (value != passController.text) {
                        return "Please Enter Same Password";
                      }
                      return null;
                    },
                    obscureText: !confirmPassWordVisible,
                    decoration: myDecor(
                      hint: "Re_type to Confirm password",
                      label: "Confirm Password",
                      isPassword: true,
                      passWordVisible: confirmPassWordVisible,
                      onTap: () {
                        confirmPassWordVisible = !confirmPassWordVisible;
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
                    UserCredential userCred = await auth!.createUserWithEmailAndPassword(email: emailController.text, password: passController.text);
                    if(userCred.user != null){


                      await userRef!.doc(userCred.user!.uid).set({
                        "name" : nameController.text,
                        "email" : emailController.text,
                        "mobile" : mobileController.text,
                        "uid" : userCred.user!.uid,
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account Created Successfully")));
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something Went Wrong")));
                    }
                  }
                  on FirebaseAuthException catch(e){
                    if(e.code == "weak-password") {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("The password provided is too weak")));
                    }
                    else if(e.code == "email-already-in-use"){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString())));
                    }
                  }
                  catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              }, child: Text("Sign Up")),
              SizedBox(height: 11),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already Have an Account ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "Log In",
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
