import 'package:flutter/material.dart';
import 'package:whatsapp/data/mock_data.dart';
import 'package:whatsapp/models/chat_item_model.dart';
import 'package:whatsapp/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<MessageModel> _messages;
  bool _typing = false;
  late AnimationController _sendCtrl;

  @override
  void initState() {
    super.initState();
    _messages = List.of(MockData.messages[widget.chat.id] ?? []);
    _controller.addListener(() {
      setState(() => _typing = _controller.text.trim().isNotEmpty);
    });
    _sendCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final msg = MessageModel(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.chat.id,
      text: text,
      time: DateTime.now(),
      fromMe: true,
    );
    _sendCtrl.forward(from: 0.0);
    setState(() => _messages.add(msg));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 32,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 4),
            Hero(
              tag: 'avatar_${widget.chat.id}',
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.chat.avatarUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.chat.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.videocam_outlined),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 700 : double.infinity),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, // added horizontal padding
                    vertical: 12,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    return AnimatedMessageBubble(
                      key: ValueKey(m.id),
                      message: m,
                    );
                  },
                ),
              ),
              _Composer(
                controller: _controller,
                focusNode: _focusNode,
                typing: _typing,
                sendScale: _sendCtrl,
                onSend: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool typing;
  final VoidCallback onSend;
  final AnimationController sendScale;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.typing,
    required this.onSend,
    required this.sendScale,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.emoji_emotions_outlined),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withAlpha(38),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Message',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ScaleTransition(
              scale: Tween(
                begin: 1.0,
                end: 1.25,
              ).chain(CurveTween(curve: Curves.easeOutBack)).animate(sendScale),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      typing
                          ? cs.primary
                          : Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: typing ? onSend : null,
                  icon: Icon(typing ? Icons.send : Icons.mic),
                  color:
                      typing ? Colors.white : Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedMessageBubble extends StatefulWidget {
  final MessageModel message;
  const AnimatedMessageBubble({super.key, required this.message});

  @override
  State<AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  late final Animation<double> _slide = Tween(
    begin: 20.0,
    end: 0.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  late final Animation<double> _fade = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.fromMe;
    final bubbleColor =
        isMe
            ? Theme.of(context).colorScheme.primary.withAlpha(38)
            : Theme.of(context).colorScheme.surface;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return FadeTransition(
      opacity: _fade,
      child: Transform.translate(
        offset: Offset(isMe ? _slide.value : -_slide.value, 0),
        child: Padding(
          padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isMe ? 60 : 16, // left margin for received messages
            right: isMe ? 16 : 60, // right margin for sent messages
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 2),
                    bottomRight: Radius.circular(isMe ? 2 : 16),
                  ),
                ),
                child: Text(widget.message.text),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: EdgeInsets.only(
                  left: isMe ? 0 : 6,
                  right: isMe ? 6 : 0,
                ),
                child: Text(
                  _time(widget.message.time),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
