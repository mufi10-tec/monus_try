import 'package:flutter/material.dart';

class TotalCard extends StatelessWidget {
  final int totalAmount; // ഹോം പേജിൽ നിന്ന് കണക്കുകൂട്ടിയ തുക ഇങ്ങോട്ട് വാങ്ങാൻ

  const TotalCard({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            "TOTAL SPEND",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "₹$totalAmount", // തുക ഇവിടെ കാണിക്കും
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}