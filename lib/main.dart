import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(BabeApp());

class BabeApp extends StatelessWidget {
  const BabeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Babe',
      home: const MyHomePage(title: 'Babe'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      key: ValueKey(document.documentID),
      title: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF303030)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.fromLTRB(22.0, 12.0, 22.0, 12.0),
        margin: const EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(document['name']),
            ),
            Text(
              document['votes'].toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      onTap: () => Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
        await transaction.get(document.reference);
        await transaction.update(
            freshSnap.reference, {'votes': freshSnap['votes'] + 1});
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder(
          stream: Firestore.instance.collection('babies').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(top: 10.0),
                itemExtent: 55.0,
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }
}