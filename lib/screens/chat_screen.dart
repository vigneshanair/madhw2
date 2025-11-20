import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  final String boardId;
  final String boardTitle;

  const ChatScreen({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = await FirestoreService.instance.getUserProfile(user.uid);
    final data = profile.data() ?? {};
    final name = (data['firstName'] ?? user.email ?? 'User') as String;

    await FirestoreService.instance.sendMessage(
      boardId: widget.boardId,
      text: text,
      uid: user.uid,
      displayName: name,
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(widget.boardTitle)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.instance.messagesStream(widget.boardId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final createdAt = data['createdAt'] as Timestamp?;
                    final uid = data['uid'] as String? ?? '';
                    final displayName =
                        data['displayName'] as String? ?? 'User';
                    final text = data['text'] as String? ?? '';

                    return MessageTile(
                      text: text,
                      displayName: displayName,
                      createdAt: createdAt?.toDate(),
                      isMe: currentUser != null && currentUser.uid == uid,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble widget (was previously in message_tile.dart)
// ---------------------------------------------------------------------------

class MessageTile extends StatelessWidget {
  final String text;
  final String displayName;
  final DateTime? createdAt;
  final bool isMe;

  const MessageTile({
    super.key,
    required this.text,
    required this.displayName,
    required this.createdAt,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = createdAt != null
        ? '${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}'
        : '';

    final bubbleColor =
        isMe ? const Color(0xFF6366F1) : const Color(0xFF111827);

    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$displayName  ·  $timeString',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
