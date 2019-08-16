import 'package:flutter/material.dart';

import 'views/AddContactPage.dart';
import 'views/ContactListPage.dart';


void main() => runApp(ContactsExampleApp());

class ContactsExampleApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactListPage(),
      routes: <String, WidgetBuilder>{
        '/add': (BuildContext context) => AddContactPage()
      },
    );
  }
}


