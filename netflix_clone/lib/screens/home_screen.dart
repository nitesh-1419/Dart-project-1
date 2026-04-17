import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import 'movie_details_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'download_screen.dart';
import 'fast_laughs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> trendingMovies = [];
  List<Movie> topRatedMovies = [];
  List<Movie> upcomingMovies = [];
  List<Movie> nowPlayingMovies = [];
  bool isLoading = true;
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    loadData();
    _scrollController.addListener(() {
      setState(() {
        _appBarOpacity = (_scrollController.offset / 200).clamp(0.0, 1.0);
      });
    });
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final trending = await TmdbService.getTrending();
    final topRated = await TmdbService.getTopRated();
    final upcoming = await TmdbService.getUpcoming();
    final nowPlaying = await TmdbService.getNowPlaying();
    
    if (mounted) {
      setState(() {
        trendingMovies = trending;
        topRatedMovies = topRated;
        upcomingMovies = upcoming;
        nowPlayingMovies = nowPlaying;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.black.withValues(alpha: _appBarOpacity),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/f/ff/Netflix-new-icon.png',
                    height: 35,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: const DecorationImage(
                          image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/0/0b/Netflix-avatar.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        backgroundColor: Colors.black,
        color: Colors.red,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 10),
              _buildSectionHeader('Trending Now'),
              _buildMovieRow(trendingMovies),
              _buildSectionHeader('Top Rated'),
              _buildMovieRow(topRatedMovies),
              _buildSectionHeader('Upcoming Movies'),
              _buildMovieRow(upcomingMovies),
              _buildSectionHeader('Now Playing'),
              _buildMovieRow(nowPlayingMovies),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'New & Hot'),
          BottomNavigationBarItem(icon: Icon(Icons.tag_faces_outlined), label: 'Fast Laughs'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.download_for_offline_outlined), label: 'Downloads'),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 1:
              loadData();
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FastLaughsScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DownloadScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    if (isLoading) return _buildHeroShimmer();
    if (trendingMovies.isEmpty) return const SizedBox(height: 500);
    
    final heroMovie = trendingMovies[0];
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CachedNetworkImage(
          imageUrl: '$imageBaseUrl${heroMovie.posterPath}',
          height: 550,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          height: 550,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
                const Color(0xFF141414),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeroButton(Icons.add, 'My List'),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: heroMovie)),
                  );
                },
                icon: const Icon(Icons.play_arrow, color: Colors.black, size: 30),
                label: const Text('Play', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              _buildHeroButton(Icons.info_outline, 'Info'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMovieRow(List<Movie> movies) {
    if (isLoading) return _buildRowShimmer();
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: movie)),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: '$imageBaseUrl${movie.posterPath}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                  errorWidget: (context, url, error) => const Icon(Icons.movie, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroShimmer() {
    return Container(
      height: 550,
      color: Colors.grey[900],
    );
  }

  Widget _buildRowShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 10),
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
