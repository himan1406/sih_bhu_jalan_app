import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_size_text/auto_size_text.dart'; // 🔹 for adaptive text
import 'services/api_services.dart';

class AnalyticsPage extends StatefulWidget {
  final String district;
  final String block;

  const AnalyticsPage({super.key, required this.district, required this.block});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _extras;
  String? _plotBase64;
  bool _loading = true;
  String? _fatalError;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final extras = await ApiService.getExtras(widget.district, widget.block);
      final plot =
      await ApiService.getPlotMeanLevels(widget.district, widget.block);

      if (!mounted) return;
      setState(() {
        _extras = extras.isNotEmpty ? extras : null;
        _plotBase64 = plot;
        _loading = false;
        _fatalError = null;
      });

      _animController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _extras = null;
        _plotBase64 = null;
        _loading = false;
        _fatalError = e.toString();
      });
    }
  }

  // ---------- Helpers ----------
  Widget _buildShimmerBox({double height = 100, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.4),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAnimatedStat(String label, dynamic value,
      {required IconData icon, String suffix = ""}) {
    final target = (value is num) ? value.toDouble() : 0.0;

    return Expanded( // 🔹 ensures equal width for all stat cards
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final display =
                (target * _animController.value).toStringAsFixed(1);
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$display$suffix",
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, String? title, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Row(
              children: [
                if (icon != null) Icon(icon, color: Colors.white, size: 18),
                if (icon != null) const SizedBox(width: 6),
                Expanded(
                  child: AutoSizeText(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    maxLines: 1,
                    minFontSize: 12, // 🔹 shrink text if space is tight
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (title != null) const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Full gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: _loading
                ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _buildShimmerBox(height: 20, width: 150),
                  ]),
                  const SizedBox(height: 20),
                  _buildCard(child: _buildShimmerBox(height: 200)),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerBox(
                              height: 120, width: double.infinity)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _buildShimmerBox(
                              height: 120, width: double.infinity)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _buildShimmerBox(
                              height: 120, width: double.infinity)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildShimmerBox(
                            height: 20, width: double.infinity),
                        const SizedBox(height: 10),
                        _buildShimmerBox(
                            height: 20, width: double.infinity),
                      ],
                    ),
                  ),
                ],
              ),
            )
                : _fatalError != null
                ? Center(
              child: Text(
                "❌ Error: $_fatalError",
                style: const TextStyle(
                    color: Colors.red, fontSize: 16),
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text("Uttar Pradesh",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            Text(
                              "${widget.district}, ${widget.block}",
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Graph
                  _buildCard(
                    title: "Mean Water Levels (Last 10 days)",
                    icon: Icons.show_chart,
                    child: _plotBase64 != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(_plotBase64!),
                        fit: BoxFit.contain,
                      ),
                    )
                        : const Center(
                      child: Text("⚠️ No graph available",
                          style: TextStyle(
                              color: Colors.white70)),
                    ),
                  ),

                  // Stats row (aligned & equal)
                  Row(
                    children: [
                      _buildAnimatedStat(
                          "Rainfall", _extras?['rainfall_mm'],
                          icon: Icons.cloud, suffix: " mm"),
                      _buildAnimatedStat(
                          "Water Table", _extras?['last_water_level'],
                          icon: Icons.water_drop, suffix: " m"),
                      _buildAnimatedStat(
                          "Score", _extras?['final_score_pct'],
                          icon: Icons.speed, suffix: "%"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Detailed Info
                  if (_extras != null)
                    _buildCard(
                      title: "Detailed Info",
                      icon: Icons.info,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📅 Last Date: ${_extras?['last_date']}",
                              style: const TextStyle(
                                  color: Colors.white70)),
                          Text("🪨 Aquifer: ${_extras?['aquifer_type']}",
                              style: const TextStyle(
                                  color: Colors.white70)),
                          Text(
                              "📈 Fluctuation: ${_extras?['daily_fluctuation']}",
                              style: const TextStyle(
                                  color: Colors.white70)),
                          const SizedBox(height: 8),
                          const Text("🌱 Yield:",
                              style:
                              TextStyle(color: Colors.white70)),
                          Text(_extras?['yield']?.toString() ?? "N/A",
                              style: const TextStyle(
                                  color: Colors.white)),
                        ],
                      ),
                    ),

                  // Water Quality
                  if (_extras != null &&
                      _extras!['water_quality'] != null)
                    _buildCard(
                      title: "Water Quality",
                      icon: Icons.water_drop,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (_extras!['water_quality']
                        as Map<String, dynamic>)
                            .entries
                            .map(
                              (e) => Text("${e.key}: ${e.value}",
                              style: const TextStyle(
                                  color: Colors.white70)),
                        )
                            .toList(),
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
    _animController.dispose();
    super.dispose();
  }
}
