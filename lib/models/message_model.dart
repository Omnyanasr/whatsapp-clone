class MessageModel {
  final String id;
  final String chatId;
  final String text;
  final DateTime time;
  final bool fromMe;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.text,
    required this.time,
    required this.fromMe,
  });
}
