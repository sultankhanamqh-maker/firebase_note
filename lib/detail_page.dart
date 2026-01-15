import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_note/ui_helper/ui_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget{
  Stream<QuerySnapshot> note;
  DetailPage({required this.note});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Notes"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: note, builder: (context,snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                return ListTile(
                  leading: Text("${index + 1}"),
                  title: Text(data["note"], style: TextTheme
                      .of(context)
                      .headlineLarge,),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["desc"], style: TextTheme
                          .of(context)
                          .bodySmall,),
                      Text(formatTime(data["created_at"]), style: TextTheme
                          .of(context)
                          .bodySmall,)
                    ],
                  ),

                );
              }) : Center(child: Text("No Notes Yet"),);
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return Container();
      }));
  }
}