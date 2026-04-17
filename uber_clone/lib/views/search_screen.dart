import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/map_services.dart';

class SearchScreen extends StatefulWidget {
  final bool isStartLocation;
  final Function(LatLng, String)? onLocationSelected;

  const SearchScreen({
    super.key,
    this.isStartLocation = true,
    this.onLocationSelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final GeocodingService _geocodingService = GeocodingService();
  List<dynamic> _results = [];
  bool _isSearching = false;

  void _search(String query) async {
    if (query.length < 3) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);
    final results = await _geocodingService.searchPlaces(query);
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isStartLocation ? 'Choose start location' : 'Choose destination',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _destinationController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Where to?',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              onChanged: _search,
            ),
          ),
          if (_isSearching)
            const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.transparent),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final place = _results[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[900], shape: BoxShape.circle),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        place['display_name'], 
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        final double lat = double.parse(place['lat'].toString());
                        final double lon = double.parse(place['lon'].toString());
                        final latLng = LatLng(lat, lon);
                        if (widget.onLocationSelected != null) {
                          widget.onLocationSelected!(latLng, place['display_name']);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    Divider(color: Colors.grey[900], indent: 70),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
