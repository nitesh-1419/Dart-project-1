import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const rides = <Map<String, String>>[
      <String, String>{
        'title': 'Airport Terminal 2',
        'subtitle': 'From MG Road',
        'fare': 'INR 480',
        'status': 'Completed',
      },
      <String, String>{
        'title': 'Work commute',
        'subtitle': 'From Indiranagar',
        'fare': 'INR 210',
        'status': 'Completed',
      },
      <String, String>{
        'title': 'Evening dinner',
        'subtitle': 'From Koramangala',
        'fare': 'INR 320',
        'status': 'Scheduled',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const Text(
              'Activity',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101514),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Recent rides and upcoming plans in one place.',
              style: TextStyle(color: Color(0xFF5C6762), height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10251C),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'This month',
                    style: TextStyle(
                      color: Color(0xFFC5D0CB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '9 rides',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Most frequent destination: Airport corridor',
                    style: TextStyle(color: Color(0xFFD7E1DC)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...rides.map(
              (ride) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RideHistoryCard(
                  title: ride['title']!,
                  subtitle: ride['subtitle']!,
                  fare: ride['fare']!,
                  status: ride['status']!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideHistoryCard extends StatelessWidget {
  const _RideHistoryCard({
    required this.title,
    required this.subtitle,
    required this.fare,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String fare;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFE5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: Color(0xFF133C2B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF636E69)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                fare,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101514),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == 'Completed'
                      ? const Color(0xFFE6F4EC)
                      : const Color(0xFFF5E8C9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Completed'
                        ? const Color(0xFF2E9156)
                        : const Color(0xFFA66D15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
