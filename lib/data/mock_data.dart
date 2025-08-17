import 'package:whatsapp/models/chat_item_model.dart';
import 'package:whatsapp/models/message_model.dart';
import 'package:whatsapp/models/story_model.dart';

class MockData {
  static final List<ChatModel> chats = List.generate(12, (i) {
    return ChatModel(
      id: 'c$i',
      name: i == 0 ? 'Omnya' : 'Friend $i',
      avatarUrl: 'https://i.pravatar.cc/150?img=${(i + 5) % 70}',
      lastMessage:
          [
            'On my way!',
            'That sounds great 👍',
            'Check this out',
            'Voice call missed',
            'Photo',
            'See you at 6?',
          ][i % 6],
      lastTime: DateTime.now().subtract(Duration(minutes: 7 * (i + 1))),
      unread: i % 4 == 0 ? (i % 3) + 1 : 0,
    );
  });

  static final Map<String, List<MessageModel>> messages = {
    for (final c in chats)
      c.id: List.generate(14, (i) {
        final fromMe = i % 3 == 0;
        return MessageModel(
          id: 'm${c.id}-$i',
          chatId: c.id,
          text:
              fromMe
                  ? ['Okay!', 'I\'m sending it now', 'Let\'s do it'][i % 3]
                  : ['Hi!', 'Can you check?', 'Cool'][i % 3],
          time: DateTime.now().subtract(Duration(minutes: 90 - i * 5)),
          fromMe: fromMe,
        );
      }),
  };

  static final List<StoryModel> stories = List.generate(10, (i) {
    return StoryModel(
      id: 's$i',
      userName: i == 0 ? 'My Status' : 'Friend $i',
      avatarUrl: 'https://i.pravatar.cc/150?img=${(i + 10) % 70}',
      mediaUrls: List.generate(
        3,
        (j) => 'https://picsum.photos/seed/${i * 10 + j}/1080/1920',
      ),
      postedAt: DateTime.now().subtract(Duration(hours: i * 3 + 1)),
    );
  });
}
