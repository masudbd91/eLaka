enum MessageType { text, image, offer, system }

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final String? imageUrl;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.type,
    this.metadata,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      type: MessageType.values.firstWhere(
            (e) => e.toString() == 'MessageType.${map['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      metadata: map['metadata'],
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    String? imageUrl,
    MessageType? type,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
