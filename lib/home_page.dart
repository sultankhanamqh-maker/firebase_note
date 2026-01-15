import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_note/app_constants.dart';
import 'package:fire_note/detail_page.dart';
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


  String formatTime(Timestamp timeStamp){

    DateTime df= timeStamp.toDate();
    
    var hour = df.hour;
    var minute = df.minute;
    var second = df.second;


    return "$hour:$minute:$second";

  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController searchController = TextEditingController();

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
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: TextField(
              onChanged: (_){
                setState(() {});
              },
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search Note here ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

            ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("Notes",style: TextTheme.of(context).headlineSmall,),
              TextButton(onPressed: (){

                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(note:note!.snapshots())));
              }, child: Text("See All",style: TextTheme.of(context).bodyMedium!.copyWith(color: Colors.blue),))
            ],),
          ),
          note == null ? Center(child: CircularProgressIndicator()) : Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: searchController.text.isEmpty ? note!.orderBy("created_at", descending: true).limit(10).snapshots() :note!.orderBy("note", descending: true).where("note", isGreaterThanOrEqualTo: searchController.text)
                .where("note", isLessThanOrEqualTo: '${searchController.text}\uf8ff').limit(20).snapshots(), builder: (context,snapshot){
              if(snapshot.hasData){
                return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context,index){
                      var data = snapshot.data!.docs.reversed.toList()[index];
                      return ListTile(
                        leading: Text("${index+1}"),
                        title: Text(data["note"],style: TextTheme.of(context).headlineLarge,),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data["desc"],style: TextTheme.of(context).bodySmall,),
                            if(data["created_at"] != null)
                            Text((formatTime(data["created_at"])),style: TextTheme.of(context).bodySmall,)
                          ],
                        ),
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
          ),
        ],
      ),
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
                         "created_at": FieldValue.serverTimestamp()
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
