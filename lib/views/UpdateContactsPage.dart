import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

import 'UpdateContactsPageState.dart';

class UpdateContactsPage extends StatefulWidget {
  UpdateContactsPage({ @required this.contact });
  final Contact contact;
  @override
  UpdateContactsPageState createState() => UpdateContactsPageState();
}