import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FireStoreService fireStoreService = FireStoreService();
  //text controller
  final TextEditingController textController = TextEditingController();
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docID == null) {
                        fireStoreService.addNote(textController.text);
                      }
                      //update existing note
                      else {
                        fireStoreService.updateNote(docID, textController.text);
                      }
                      //clear text controler
                      textController.clear();
                      //close box
                      Navigator.pop(context);
                    },
                    child: Text('Add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            //display has list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each individual data
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    //update button
                    IconButton(
                    onPressed: () => openNoteBox(docID:docID),
                    icon: const Icon(Icons.settings),
                  ),
                  //delete button
                  IconButton(
                    onPressed: () => fireStoreService.deleteNote(docID),
                    icon: const Icon(Icons.delete),
                  )
                  ],),
                );
              },
            );
          } else {
            return const Text('No notes....');
          }
        },
      ),
    );
  }
}
