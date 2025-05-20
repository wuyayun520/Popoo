import 'package:flutter/material.dart';

class StatisticsModule extends StatefulWidget {
  const StatisticsModule({super.key});

  @override
  State<StatisticsModule> createState() => _StatisticsModuleState();
}

class _StatisticsModuleState extends State<StatisticsModule> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bar_chart,
            size: 80,
            color: Color(0xFF69ACFF),
          ),
          const SizedBox(height: 16),
          const Text(
            'Statistics Module',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF69ACFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'View data analytics and reports',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Navigate to statistics details or actions
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF69ACFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Reports',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 