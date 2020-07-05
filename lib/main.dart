import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(FriendlyChatApp());
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final List<ChatMessage> _messages = []; //Список для сообщений
  final FocusNode _focusNode = FocusNode(); //Возврат фокуса
  bool _isComposing = false;

  Widget _buildeTextComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              controller: _textController,
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: InputDecoration.collapsed(hintText: "Send message"),
              focusNode: _focusNode,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send),
              color: Colors.blue,
              onPressed: _isComposing
                  ? () => _handleSubmitted(_textController.text) // MODIFIED
                  : null,
            ),
          )
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    _focusNode.requestFocus(); //Получение фокуса
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        elevation:
        /* Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,*/
        Theme.of(context).platform == TargetPlatform.iOS ? 4.0 : 0.0,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (_, int index) => _messages[index])),
          Divider(height: 0.8),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildeTextComposer(),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});

  final AnimationController animationController;
  final String text;
  String _name = 'Your Name';

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
          parent: animationController, curve: Curves.easeOutQuad),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          //Возвращает строку, где есть имя и аватар
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                child: Text(_name[0]), //Установка картинки первой буквы в имени
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _name,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
