import 'package:flutter/material.dart';

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
    final timeString = createdAt == null
        ? ''
        : '${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}';

    final bubbleColor = isMe
        ? const Color(0xFF4C1D95)
        : const Color(0xFF111827);

    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final rowAlign = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: rowAlign,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: align,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(text),
                      if (timeString.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          timeString,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
