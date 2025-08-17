import 'package:flutter/material.dart';
import 'package:whatsapp/data/mock_data.dart';
import 'package:whatsapp/models/story_model.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = MockData.stories;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const _MyStatusTile(),
        const Divider(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent updates',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        for (int i = 1; i < stories.length; i++)
          StoryTile(story: stories[i], index: i),
      ],
    );
  }
}

class _MyStatusTile extends StatelessWidget {
  const _MyStatusTile();
  @override
  Widget build(BuildContext context) {
    final me = MockData.stories.first;
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(radius: 26, backgroundImage: NetworkImage(me.avatarUrl)),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      title: const Text(
        'My status',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: const Text('Tap to add status update'),
      onTap: () {},
    );
  }
}

class StoryTile extends StatelessWidget {
  final StoryModel story;
  final int index;
  const StoryTile({super.key, required this.story, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) =>
                    StoryViewer(stories: MockData.stories, initialIndex: index),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(story.avatarUrl),
      ),
      title: Text(
        story.userName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(_since(story.postedAt)),
    );
  }

  String _since(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} hours ago';
    return '${d.inDays} days ago';
  }
}

class StoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  const StoryViewer({super.key, required this.stories, this.initialIndex = 0});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with TickerProviderStateMixin {
  late final PageController _friendPage;
  List<AnimationController> _progressCtrls = [];
  int _friendIndex = 0;
  int _mediaIndex = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _friendIndex = widget.initialIndex;
    _friendPage = PageController(initialPage: _friendIndex);
    _initMediaControllers();
    _startCurrent();
  }

  void _initMediaControllers() {
    // Dispose previous controllers if any
    for (final ctrl in _progressCtrls) {
      ctrl.dispose();
    }

    final story = widget.stories[_friendIndex];
    _progressCtrls =
        story.mediaUrls
            .map(
              (_) => AnimationController(
                vsync: this,
                duration: const Duration(seconds: 3),
              ),
            )
            .toList();
  }

  void _startCurrent() {
    if (_mediaIndex >= _progressCtrls.length) return;
    _progressCtrls[_mediaIndex]
      ..forward(from: 0.0)
      ..addStatusListener((st) {
        if (st == AnimationStatus.completed) _nextMedia();
      });
  }

  void _nextMedia() {
    if (_mediaIndex < _progressCtrls.length - 1) {
      setState(() => _mediaIndex++);
      _startCurrent();
    } else {
      _nextFriend();
    }
  }

  void _prevMedia() {
    if (_mediaIndex > 0) {
      setState(() => _mediaIndex--);
      _startCurrent();
    } else {
      _prevFriend();
    }
  }

  void _nextFriend() {
    if (_friendIndex < widget.stories.length - 1) {
      setState(() {
        _friendIndex++;
        _mediaIndex = 0;
      });
      _initMediaControllers();
      _friendPage.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _startCurrent();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _prevFriend() {
    if (_friendIndex > 0) {
      setState(() {
        _friendIndex--;
        _mediaIndex = 0;
      });
      _initMediaControllers();
      _friendPage.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _startCurrent();
    }
  }

  void _togglePause(bool pause) {
    setState(() => _paused = pause);
    final ctrl = _progressCtrls[_mediaIndex];
    if (pause)
      ctrl.stop();
    else
      ctrl.forward();
  }

  @override
  void dispose() {
    for (final c in _progressCtrls) c.dispose();
    _friendPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_friendIndex];
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapUp: (d) {
        final w = MediaQuery.of(context).size.width;
        if (d.localPosition.dx < w * 0.33)
          _prevMedia();
        else
          _nextMedia();
      },
      onLongPressStart: (_) => _togglePause(true),
      onLongPressEnd: (_) => _togglePause(false),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _friendPage,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.stories.length,
                itemBuilder: (_, friendIndex) {
                  final story = widget.stories[friendIndex];
                  return PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: story.mediaUrls.length,
                    itemBuilder:
                        (_, mediaIndex) =>
                            _StoryImage(url: story.mediaUrls[mediaIndex]),
                  );
                },
              ),
              // Progress bars
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    for (int i = 0; i < story.mediaUrls.length; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == story.mediaUrls.length - 1 ? 0 : 4,
                          ),
                          child: AnimatedBuilder(
                            animation: _progressCtrls[i],
                            builder: (context, _) {
                              final v =
                                  i < _mediaIndex
                                      ? 1.0
                                      : i > _mediaIndex
                                      ? 0.0
                                      : _progressCtrls[i].value;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: v,
                                  minHeight: 3,
                                  backgroundColor: Colors.white24,
                                  color: cs.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Header
              Positioned(
                top: 16,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(story.avatarUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _since(story.postedAt),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _since(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

class _StoryImage extends StatelessWidget {
  final String url;
  const _StoryImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
