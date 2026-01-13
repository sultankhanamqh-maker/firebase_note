import 'package:flutter/material.dart';

class OutlinedBtn  extends StatelessWidget{
  VoidCallback onTap;
  String title;
  bool isWidget;
  Widget? widget;
  OutlinedBtn({super.key, required this.onTap,required this.title,this.isWidget = false , this.widget});
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
      style:OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        )
        ),
        onPressed: onTap ,child: isWidget ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget!,
          SizedBox(width: 11,),
          Text(title),
        ],
      ) : Text(title),),
    );
  }


}