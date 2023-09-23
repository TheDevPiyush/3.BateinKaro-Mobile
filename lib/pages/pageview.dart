import 'package:chatting_app/pages/chat_screen.dart';
import 'package:chatting_app/pages/on_users_list.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _controller = PageController(initialPage: 0);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          OnlineUsersScreen(
            ontapFunc: () {
              _controller.nextPage(
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
              );
            },
          ),
          ChatScreen(
            ontapFunc: () {
              _controller.previousPage(
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }
}
