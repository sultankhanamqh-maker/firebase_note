import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ElevatedBtn extends StatelessWidget{

  String title;
  VoidCallback onTap;
  Widget? widget;
  bool isWidget;
  Color fgColor;
  Color bgColor;



  ElevatedBtn({super.key, required this.title , required this.onTap ,this.widget,this.isWidget = false,this.bgColor = Colors.amber,this.fgColor = Colors.white});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: fgColor,
            backgroundColor: bgColor,
          ),
          onPressed: onTap, child: isWidget ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget!,
          SizedBox(width: 11,),
          Text(title),
        ],
      ) : Text(title)),
    );


  }

}