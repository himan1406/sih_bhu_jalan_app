import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/api_services.dart';

class AnalyticsPage extends StatefulWidget {
  final String district;
  final String block;

  const AnalyticsPage({super.key, required this.district, required this.block});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _extras;
  String? _plotBase64;
  bool _loading = true;

  // Optional: top-level error (e.g., server down)
  String? _fatalError;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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

      _controller.forward();
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

  // ---------- helpers ----------
  String formatNumber(dynamic value, {int decimals = 2, String suffix = ""}) {
    if (value == null) return "--";
    try {
      return "${double.parse(value.toString()).toStringAsFixed(decimals)}$suffix";
    } catch (_) {
      return value.toString();
    }
  }

  // Prefer numeric display, otherwise show reason text
  String displayValueOrReason({
    required dynamic value,
    String? reason,
    int decimals = 2,
    String suffix = "",
  }) {
    if (value == null) {
      return (reason == null || reason.isEmpty) ? "--" : reason;
    }
    return formatNumber(value, decimals: decimals, suffix: suffix);
  }

  Widget _buildInfoRow(String label, dynamic value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: Colors.white70, size: 18),
          if (icon != null) const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "$label: ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: value?.toString() ?? "--",
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, String? title}) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1E3F), // solid dark blue
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotice(String text, {Color color = const Color(0xFFB00020)}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/cgwb_bg.png", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),

          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_fatalError != null)
          // hard failure (network/timeout/etc.)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildNotice(
                  "Failed to fetch data: $_fatalError",
                  color: const Color(0xFFFFC107),
                ),
              ),
            )
          else if (_extras == null && _plotBase64 == null)
              const Center(
                child: Text(
                  "No data found",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            else
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Location Header ----------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Uttar Pradesh",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${widget.district}, ${widget.block}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---------- Optional server-side error banner ----------
                    if (_extras != null && _extras!['error'] != null)
                      _buildNotice("Server message: ${_extras!['error']}"),

                    // ---------- Graph Card ----------
                    _buildCard(
                      title: "📊 Mean Water Levels (last 10 days)",
                      child: _plotBase64 != null
                          ? Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(_plotBase64!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                          : Center(
                        child: Text(
                          // prefer reason if backend sent a message
                          _extras != null &&
                              _extras!['plot_reason'] != null &&
                              _extras!['plot_reason'].toString().isNotEmpty
                              ? _extras!['plot_reason'].toString()
                              : "⚠️ No graph available.\n(Need at least 10 days of data)",
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // ---------- Key Stats (3 tiles row) ----------
                    if (_extras != null)
                      _buildCard(
                        title: "Key Stats",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Rainfall
                            Column(
                              children: [
                                const Icon(Icons.cloud, color: Colors.white),
                                Text(
                                  displayValueOrReason(
                                    value: _extras?['rainfall_mm'],
                                    reason: null, // usually direct value
                                    decimals: 1,
                                    suffix: " mm",
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Rainfall",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            // Water level
                            Column(
                              children: [
                                const Icon(Icons.water_drop, color: Colors.white),
                                Text(
                                  displayValueOrReason(
                                    value: _extras?['last_water_level'],
                                    reason: null, // usually direct value
                                    decimals: 2,
                                    suffix: " m",
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Water Level",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            // Score
                            Column(
                              children: [
                                const Icon(Icons.speed, color: Colors.white),
                                Text(
                                  displayValueOrReason(
                                    value: _extras?['final_score_pct'],
                                    reason: _extras?['score_reason'],
                                    decimals: 1,
                                    suffix: _extras?['final_score_pct'] == null
                                        ? ""
                                        : "%",
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Text("Score",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // ---------- Detailed Info ----------
                    if (_extras != null)
                      _buildCard(
                        title: "ℹ️ Detailed Info",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("📅 Last Measured",
                                _extras?['last_date'],
                                icon: Icons.calendar_today),
                            _buildInfoRow("🪨 Aquifer", _extras?['aquifer_type'],
                                icon: Icons.layers),
                            _buildInfoRow(
                              "📈 Daily Fluctuation",
                              displayValueOrReason(
                                value: _extras?['daily_fluctuation'],
                                reason: _extras?['fluct_reason'],
                                decimals: 2,
                              ),
                              icon: Icons.show_chart,
                            ),
                            _buildInfoRow(
                              "📊 Yield",
                              displayValueOrReason(
                                value: _extras?['yield'],
                                reason: _extras?['yield_reason'],
                                decimals: 2,
                                suffix: _extras?['yield'] == null ? "" : " m³",
                              ),
                              icon: Icons.grass,
                            ),
                          ],
                        ),
                      ),

                    // ---------- Water Quality ----------
                    if (_extras != null &&
                        _extras!['water_quality'] != null &&
                        _extras!['water_quality'] is Map)
                      _buildCard(
                        title: "💧 Water Quality",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (_extras!['water_quality']
                          as Map<String, dynamic>)
                              .entries
                              .map((entry) => _buildInfoRow(
                              entry.key, formatNumber(entry.value)))
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 20), // bottom padding
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
