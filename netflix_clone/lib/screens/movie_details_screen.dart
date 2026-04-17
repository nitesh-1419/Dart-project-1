import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late YoutubePlayerController _controller;
  String? _trailerKey;

  bool _isDownloading = false;
  double _downloadProgress = 0.0; // ✅ FIXED

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    _loadTrailer();
  }

  Future<void> _loadTrailer() async {
    final key = await TmdbService.getMovieTrailer(widget.movie.id);

    if (!mounted) return;

    setState(() {
      _trailerKey = key ?? 'dQw4w9WgXcQ';
    });

    _controller.loadVideoById(videoId: _trailerKey!);
  }

  void _startMockDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      setState(() {
        _downloadProgress = i / 100;
      });
    }

    setState(() {
      _isDownloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.movie.title} downloaded!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [

    SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _trailerKey != null
            ? YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              )
            : Container(color: Colors.grey[900]),
      ),
    ),


          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🎬 Movie Title
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ▶ Play Button
                  ElevatedButton.icon(
                    onPressed: () => _controller.playVideo(),
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text(
                      'Play',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⬇ Download Button
                  ElevatedButton.icon(
                    onPressed: _startMockDownload,
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // 📊 Progress Bar
                  if (_isDownloading) ...[
                    const SizedBox(height: 15),

                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.grey,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${(_downloadProgress * 100).toInt()}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 📝 Overview
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}