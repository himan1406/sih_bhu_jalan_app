import 'package:flutter/material.dart';
import 'services/api_services.dart';

class ComparisonPage extends StatefulWidget {
  final List<Map<String, String>> selectedPairs;

  const ComparisonPage({super.key, required this.selectedPairs});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  Map<String, Map<String, dynamic>> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    Map<String, Map<String, dynamic>> results = {};
    for (var pair in widget.selectedPairs) {
      final district = pair["district"]!;
      final block = pair["block"]!;
      try {
        final extras = await ApiService.getExtras(district, block);
        results["$district - $block"] = extras;
      } catch (e) {
        results["$district - $block"] = {"error": e.toString()};
      }
    }
    setState(() {
      _data = results;
      _loading = false;
    });
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          Expanded(
            child: Text(value?.toString() ?? "--",
                style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Map<String, dynamic> extras) {
    final hasError = extras.containsKey("error");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B054C),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: hasError
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.redAccent)),
          const SizedBox(height: 6),
          Text(extras["error"] ?? "Error fetching data",
              style: const TextStyle(color: Colors.white70)),
        ],
      )
          : ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            if (extras["final_score_pct"] != null)
              Chip(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                label: Text(
                  "${extras["final_score_pct"]}%",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("📅 Last Date", extras["last_date"]),
                _buildInfoRow("🪨 Aquifer", extras["aquifer_type"]),
                _buildInfoRow("🌧 Rainfall (mm)", extras["rainfall_mm"]),
                _buildInfoRow("📉 Water Level (m)", extras["last_water_level"]),
                _buildInfoRow("📊 Score", extras["final_score_pct"]),
                _buildInfoRow(
                    "📈 Daily Fluctuation", extras["daily_fluctuation"]),
                _buildInfoRow("🌱 Yield (m³)", extras["yield"]),
                const SizedBox(height: 10),
                const Text("💧 Water Quality",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 6),
                if (extras["water_quality"] != null &&
                    extras["water_quality"] is Map<String, dynamic>)
                  ...((extras["water_quality"] as Map<String, dynamic>)
                      .entries
                      .map((e) => _buildInfoRow(e.key, e.value))
                      .toList())
                else
                  const Text("No water quality data",
                      style: TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/cgwb_bg.png", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.25)),

          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_data.isEmpty)
            const Center(
                child: Text("No data found",
                    style: TextStyle(color: Colors.white, fontSize: 18)))
          else
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset("assets/cgwb_logo.png", width: 90, height: 120),
                    const SizedBox(height: 10),
                    const Text("BHU-JALAN",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Comparison Dashboard",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white70)),
                    const SizedBox(height: 30),
                    Column(
                      children: _data.entries
                          .map((entry) => _buildCard(entry.key, entry.value))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
