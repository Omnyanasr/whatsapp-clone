import 'package:flutter/material.dart';
import 'package:whatsapp/views/chats_screen.dart';
import 'package:whatsapp/views/stories_screen.dart';

class HomeShell extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeShell({super.key, required this.onToggleTheme});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'theme') {
                widget.onToggleTheme();
              }
              // you can handle other menu actions here
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'new_group', child: Text('New group')),
                  PopupMenuItem(value: 'settings', child: Text('Settings')),
                  PopupMenuItem(value: 'theme', child: Text('Change Theme')),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium!.color,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [Tab(text: 'Chats'), Tab(text: 'Stories')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [ChatsScreen(), StoriesScreen()],
      ),
      floatingActionButton:
          _tab.index == 0
              ? FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.chat),
              )
              : FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.camera_alt),
              ),
    );
  }
}
