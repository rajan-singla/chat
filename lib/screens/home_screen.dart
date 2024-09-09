import 'package:chat/api/apis.dart';
import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/screens/profile_screen.dart';
import 'package:chat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _users = <ChatUser>[];
  List<ChatUser> _searchUsers = <ChatUser>[];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  Future<void> _signOut() async {
    if (APIs.auth.currentUser != null) {
      await APIs.auth.signOut();
      await GoogleSignIn().signOut();
    }
  }

  // To handle the Will pop scope on device back gesture
  void _popScope(bool didPop) {
    if (didPop) {
      return;
    }

    if (_isSearching) {
      setState(() {
        _isSearching = !_isSearching;
      });
      return;
    } else {
      // To exit from the app
      SystemNavigator.pop();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvoked: _popScope,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(CupertinoIcons.home),
              onPressed: () {},
            ),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter name or email...'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    //when search text changes then updated search list
                    onChanged: (val) {
                      // Clear the serched list
                      _searchUsers.clear();

                      // match the searched user and add them in the [_searchUsers] list
                      for (var user in _users) {
                        if (user.name
                                .toLowerCase()
                                .contains(val.toLowerCase().trim()) ||
                            user.email
                                .toLowerCase()
                                .contains(val.toLowerCase().trim())) {
                          _searchUsers.add(user);
                        }
                      }

                      // Update the state
                      setState(() => _searchUsers);
                    },
                  )
                : Text('WhatsApp'),
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          user: APIs.me,
                        ),
                      ));
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _signOut,
            child: Icon(Icons.add_comment_outlined),
          ),
          body: StreamBuilder(
              stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _users = data
                            ?.map((user) => ChatUser.fromJson(user.data()))
                            .toList() ??
                        <ChatUser>[];
                }

                if (_users.isNotEmpty) {
                  return ListView.builder(
                    itemCount:
                        _isSearching ? _searchUsers.length : _users.length,
                    padding: EdgeInsets.only(top: mq.height * .01),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatUserCard(
                        user:
                            _isSearching ? _searchUsers[index] : _users[index],
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      'No Connections Found!',
                      style: TextStyle(
                          fontSize: TextTheme().headlineSmall?.fontSize),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
