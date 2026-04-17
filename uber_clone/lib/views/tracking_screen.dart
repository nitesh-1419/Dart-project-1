import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({
    super.key,
    required this.vehicleName,
    required this.amountLabel,
  });

  final String vehicleName;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Driver en route',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101514),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF10251C), Color(0xFF183428)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Arrival in 3 min',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your driver is finishing a nearby drop-off and heading to pickup.',
                      style: TextStyle(color: Color(0xFFD3DED8), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _TrackingCard(
                icon: Icons.local_taxi,
                title: vehicleName,
                subtitle: 'White sedan / KA 09 AB 1234',
                trailing: amountLabel,
              ),
              const SizedBox(height: 12),
              const _TrackingCard(
                icon: Icons.person_outline,
                title: 'Arjun Kumar',
                subtitle: 'Rated 4.9 / 1,248 trips completed',
                trailing: 'Call',
              ),
              const SizedBox(height: 12),
              const _TrackingCard(
                icon: Icons.verified_user_outlined,
                title: 'Safety',
                subtitle:
                    'Share trip, emergency help, and pickup verification ready.',
                trailing: 'Active',
              ),
              const SizedBox(height: 24),
              const Text(
                'Trip progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101514),
                ),
              ),
              const SizedBox(height: 14),
              const _ProgressStep(
                title: 'Ride confirmed',
                subtitle: 'Payment received and driver assigned.',
                active: true,
              ),
              const _ProgressStep(
                title: 'Driver approaching pickup',
                subtitle: 'You can contact the driver or share the trip now.',
                active: true,
              ),
              const _ProgressStep(
                title: 'Trip starts',
                subtitle: 'Your route begins once pickup is complete.',
                active: false,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Back to home',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF133C2B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5C6762),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF101514),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.active,
  });

  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2E9156) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? const Color(0xFF2E9156)
                      : const Color(0xFFCAD3CF),
                ),
              ),
            ),
            Container(width: 2, height: 42, color: const Color(0xFFD8DEDB)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: active
                        ? const Color(0xFF101514)
                        : const Color(0xFF6D7873),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5C6762),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
