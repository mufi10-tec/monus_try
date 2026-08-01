import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart'; // ഗ്രാഫ് പാക്കേജ് ഇമ്പോർട്ട് ചെയ്തു

class ExpenseChart extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const ExpenseChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // 1. നമ്മുടെ ലിസ്റ്റിലുള്ള കാര്യങ്ങൾ ഗ്രാഫിന് മനസ്സിലാകുന്ന രൂപത്തിലേക്ക് മാറ്റുന്നു
    Map<String, double> dataMap = {};

    for (var item in expenses) {
     String title = item["title"].toString().trim().toLowerCase();
      double amount = (item["amount"] as num).toDouble();

      // ഒരേ പേരിൽ ഒന്നിൽ കൂടുതൽ ചിലവുകൾ വന്നാൽ തുകകൾ തമ്മിൽ കൂട്ടാൻ വേണ്ടി
      if (dataMap.containsKey(title)) {
        dataMap[title] = dataMap[title]! + amount;
      } else {
        dataMap[title] = amount;
      }
    }

    // 2. ലിസ്റ്റ് കാലിയാണെങ്കിൽ ഗ്രാഫ് കാണിക്കാതെ ഒരു മെസ്സേജ് കാണിക്കും
    if (dataMap.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("ചിലവുകൾ ഒന്നും ചേർത്തിട്ടില്ല!", style: TextStyle(color: Colors.grey)),
      );
    }

    // 3. ഡാറ്റ ഉണ്ടെങ്കിൽ ഭംഗിയുള്ള ഗ്രാഫ് കാണിക്കുന്നു
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 2)
        ],
      ),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right, // ഐറ്റങ്ങളുടെ പേര് വലതുവശത്ത് കാണിക്കും
          showLegends: true,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true, // ശതമാന കണക്കിൽ കാണിക്കാൻ (%)]
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      ),
    );
  }
}