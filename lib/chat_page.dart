import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  types.User _user = types.User(id: const Uuid().v4(), role: types.Role.user, firstName: 'You'); // User ID
  final String apiUrl = 'https://noam.berezini.com/v1/getAnswer'; // Your API endpoint

  // Define the assistant user with an avatar
  final types.User _assistant = const types.User(
      id: 'assistant',
      firstName: 'AI Assistant',
      // imageUrl: 'http://localhost:3000/avatar',
      role: types.Role.agent// Replace with your avatar URL
  );

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Method to start a new chat, clears messages and generates a new user
  void _startNewChat() {
    setState(() {
      _messages = [];
      _user = types.User(id: const Uuid().v4(), role: types.Role.user, firstName: 'You'); // Generate new user ID
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  // Send the message to the server and get a response
  Future<void> _sendMessageToServer(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Access-Control-Allow-Origin': '*',
          "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': '${_user.id}@mail.com',
          "language": "en",
          "application": "android",
          'question': message,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the server response
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (kDebugMode) {
          print( responseData['answer']);
        }
        // Get assistant response
        final assistantMessage = types.TextMessage(
          author: _assistant, // Assign the assistant user with avatar
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: responseData['answer'],
        );

        _addMessage(assistantMessage);
      } else {
        throw Exception('Failed to get response from server');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    // Add user's message to the chat
    _addMessage(textMessage);

    // Send the message to the server and get a response
    _sendMessageToServer(message.text);
  }

  void _loadMessages() async {
    final messages = <types.Message>[];
    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chat'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _startNewChat, // Call the method to start a new chat
          tooltip: 'Start New Chat',
        ),
      ],
    ),
    body: Chat(
      messages: _messages,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
      showUserAvatars: true,
      showUserNames: true,
      user: _user,
    ),
  );
}
