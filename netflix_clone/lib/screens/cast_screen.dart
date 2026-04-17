import 'package:flutter/material.dart';

class CastScreen extends StatelessWidget {
  const CastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Cast & Crew', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://image.tmdb.org/t/p/w200/${index % 3 == 0 ? 'ry4lOtx8xGA5nOHYgsv6iIcg4o3.jpg' : 'kDRVfXcuR6wVLEmJqTyKDzRFGvQ.jpg'}'),
          ),
          title: Text('Actor ${index + 1}', style: const TextStyle(color: Colors.white)),
          subtitle: Text('Movie Role', style: TextStyle(color: Colors.grey)),
          onTap: () {},
        ),
      ),
    );
  }
}
