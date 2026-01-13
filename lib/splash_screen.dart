import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashScreen extends StatelessWidget{
  
  @override
  Widget build(BuildContext context){
    Timer(Duration(seconds: 3),()async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var  uid = prefs.getString(AppConstants.loginId)?? "";
      Widget nextPage = LoginPage();
      if(uid.isNotEmpty){
        nextPage = HomePage();
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage));
    });


    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes,size: 80,color: Colors.white,),
          Text("Notes",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
        ],
      ),),
    );
  }
}