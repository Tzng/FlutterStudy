import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms/flutter_sms.dart';

import 'ContactDetailsPage.dart';

/// 联系人列表
class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  Iterable<Contact> _contacts;

  @override
  initState() {
    super.initState();
    refreshContacts();
  }

  /// 刷新联系人
  refreshContacts() async {
    // 权限检测
    PermissionStatus permissionStatus = await _getContactPermission();
    // 如果用户授权了
    if (permissionStatus == PermissionStatus.granted) {
      // 联系人列表
      var contacts = await ContactsService.getContacts();
      // 保存
      setState(() {
        _contacts = contacts;
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  updateContact() async {
    Contact ninja = _contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  // 处理无效的权限
  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED", message: "拒绝访问", details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED", message: "定位数据在此设备上未提供", details: null);
    }
  }

  // 发送短信-单发
  void _sendOneSms(Contact contact) {
    // 目前只取第一个
    String phoneStr = contact.phones.first.value;
    print(phoneStr);
    var phones = contact.phones;
    if (phones.length == 0) {
      // 提示没有电话
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("您还没有存他的联系方式"),
              content: Text("您还没有存他的联系方式"),
              actions: <Widget>[
                FlatButton(
                  child: Text("关闭"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      return;
    }
    // TODO 对电话进行判断
    if (phones.length > 1) {
      // TODO 多个电话
    }
    // 这里的短信内容应该去服务器获取
    String message = "祝你生日快!";
    List<String> recipents = [phoneStr];
    _sendSMS(message, recipents);
  }

  // 发送短信

  void _sendSMS(String message, List<String> recipents) async {
    String _result =
        await FlutterSms.sendSMS(message: message, recipients: recipents)
            .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('联系人列表'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            // 点击之后刷新列表
            onPressed: refreshContacts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // 导航跳转
          Navigator.of(context).pushNamed("/add").then((_) {
            refreshContacts();
          });
        },
      ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = _contacts?.elementAt(index);
                  return ListTile(
                    onTap: () {
                      // 导航跳转，并传递参数
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ContactDetailsPage(c)));
                    },
                    leading: (c.avatar != null && c.avatar.length > 0)
                        ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                        : CircleAvatar(child: Text(c.initials())),
                    title: Text(c.displayName ?? ""),
                    trailing: IconButton(
                      icon: Icon(Icons.sms),
                      // 点击之后刷新列表
                      onPressed: () => _sendOneSms(c),
                    ),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
