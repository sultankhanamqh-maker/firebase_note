import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_note/app_constants.dart';
import 'package:fire_note/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore? firebaseFirestore;
   CollectionReference? note;

  bool isUpdate = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  String selectedId= "";
  @override
  void initState() {
    super.initState();
    firebaseFirestore = FirebaseFirestore.instance;
    getId();

  }
  Future<void> getId()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString(AppConstants.loginId);
    note = firebaseFirestore!.collection("users").doc(uid).collection("notes");
    if(mounted){
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: ()async{
            var prefs = await SharedPreferences.getInstance();
            prefs.setString(AppConstants.loginId, "");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage()));
          }, icon: Icon(Icons.logout_outlined))
        ],
        title: Text("Notes",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
      ),
      body: note == null ? Center(child: CircularProgressIndicator()) : StreamBuilder<QuerySnapshot>(stream: note!.snapshots(), builder: (context,snapshot){
        if(snapshot.hasData){
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index){
                var data = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(data["note"]),
                  subtitle: Text(data["desc"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: (){
                        showSheet(isUpdate: true);
                        selectedId = data.id;
                        titleController.text = data["note"];
                        descController.text = data["desc"];


                      },icon: Icon(Icons.edit),),
                      IconButton(onPressed: (){
                        note!.doc(data.id).delete();

                      },icon: Icon(Icons.delete),),
                    ],
                  ),
                );
              }): Center(child: Text("No Notes Yet"),);
        }
        if(snapshot.hasError){
          return Center(child: Text(snapshot.error.toString()));
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }
        return Container();

      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSheet();
        },
        child: Icon(Icons.add),
      ),
    );
  }
  Future<dynamic> showSheet({bool isUpdate = false}){
   return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(isUpdate ? "Update Note" : "Add Note",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: 11),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hint: Text("Enter your Note"),
                  label: Text("Note"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 11),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hint: Text("Enter your description"),
                  label: Text("Desc"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async{
                     if(isUpdate){
                       note!.doc(selectedId).update({
                         "note" : titleController.text,
                         "desc" : descController.text,
                       }).then((value) {
                         Navigator.pop(context);
                         titleController.clear();
                         descController.clear();
                       }).catchError((error){
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                       });
                     }
                     else{
                       await note!
                           .doc(
                         DateTime.now().millisecondsSinceEpoch.toString(),
                       )
                           .set({
                         "note": titleController.text,
                         "desc": descController.text,
                       }).then((value) {
                         Navigator.pop(context);
                         titleController.clear();
                         descController.clear();
                       }).catchError((error){
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                       });
                     }

                    },
                    child: Text(isUpdate ? "Update Note":"Add Note"),
                  ),
                  SizedBox(width: 11),
                  ElevatedButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: Text("Cancel")),
                ],
              ),

            ],
          ),
        );
      },
    );
  }
}
