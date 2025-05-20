import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../../models/yoga_user.dart';
import 'chat_page.dart';

class OrdersModule extends StatefulWidget {
  const OrdersModule({super.key});

  @override
  State<OrdersModule> createState() => _OrdersModuleState();
}

class _OrdersModuleState extends State<OrdersModule> {
  List<_ChatSession> _sessions = [];
  bool _loading = true;
  List<YogaUser> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadAllUsers().then((_) => _loadSessions());
  }

  Future<void> _loadAllUsers() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/jsondata/brepeople.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> usersJson = jsonData['allData'];
      setState(() {
        _allUsers = usersJson.map((json) => YogaUser.fromJson(json)).toList();
      });
    } catch (e) {
      setState(() {
        _allUsers = [];
      });
    }
  }

  Future<void> _loadSessions() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().whereType<File>().where((f) => f.path.contains('chat_history_') && f.path.endsWith('.json')).toList();
    List<_ChatSession> sessions = [];
    for (var file in files) {
      final fileName = file.path.split('/').last;
      final userId = fileName.replaceAll('chat_history_', '').replaceAll('.json', '');
      final jsonStr = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonStr);
      if (jsonList.isEmpty) continue;
      final lastMsg = jsonList.last;
      final user = _getUserById(userId);
      if (user != null) {
        sessions.add(_ChatSession(
          user: user,
          lastMsg: lastMsg['text'] ?? (lastMsg['imagePath'] != null ? '[Image]' : (lastMsg['audioPath'] != null ? '[Audio]' : '')),
          time: lastMsg['time'] ?? '',
        ));
      }
    }
    // 按时间倒序排列
    sessions.sort((a, b) => b.time.compareTo(a.time));
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  YogaUser? _getUserById(String userId) {
    try {
      return _allUsers.firstWhere((u) => u.userId == userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_sessions.isEmpty) {
      return Center(
        child: Text('No messages yet', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
      );
    }
    return ListView.separated(
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(session.user.profilePicture),
            radius: 26,
          ),
          title: Text(session.user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(session.lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(session.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatPage(user: session.user)),
            );
          },
        );
      },
    );
  }
}

class _ChatSession {
  final YogaUser user;
  final String lastMsg;
  final String time;
  _ChatSession({required this.user, required this.lastMsg, required this.time});
} 