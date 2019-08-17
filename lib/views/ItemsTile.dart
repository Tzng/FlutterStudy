import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

/// 如果有多个
class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);
  final Iterable<Item> _items;
  final String _title;

  // 国际化对象
  final Map _locale = {
    'mobile': '手机',
    'home': '住宅',
    'work': '单位',
    'other': '其他',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items.map((i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              title: Text(_locale[i.label] ??  ""),
              trailing: Text(i.value ?? ""),
            ),),
          ).toList(),
        ),
      ],
    );
  }
}
