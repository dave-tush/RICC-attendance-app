import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/Provider/new_provider.dart';
import 'package:flutter/material.dart';



class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController controller = TextEditingController();
  void openNoteBox(){
    showDialog(context: context, builder: (context) => AlertDialog(content: TextField(
      controller: controller,
    ),actions: [
      ElevatedButton(onPressed: (){
        firestoreService.addNote(controller.text);
        controller.clear();
        Navigator.pop(context);
      }, child: Text('add'))
    ],));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('data'),),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(stream: firestoreService.getNoteStream(), builder: (context, snapShot) {
            if(snapShot.hasData){
              List  noteList = snapShot.data!.docs;

              return Expanded(
                child: ListView.builder(itemCount: noteList.length,itemBuilder: (context,index) {
                  DocumentSnapshot document = noteList[index];
                  String docID = document.id;
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String noteText = data['note'];
                  return ListTile(
                    title: Text(noteText),
                  );
                }),
              );
            }else {
              return Text('no data');
            }
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: openNoteBox),
    );
  }
}
