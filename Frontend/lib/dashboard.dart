import 'package:flutter/material.dart';
import 'groundwater.dart';
import 'comparison.dart';
import 'info.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard(Widget card, int index) {
    final delay = index * 200;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double value = (_controller.value * 1000).clamp(0, 1200);
        if (value < delay) return const SizedBox();
        return FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(position: _slideAnim, child: child),
        );
      },
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/cgwb_bg.png", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  // 🔹 Logo + Title
                  Column(
                    children: [
                      Image.asset("assets/cgwb_logo.png",
                          width: 110, height: 150),
                      const SizedBox(height: 10),
                      const Text(
                        "BHU-JALAN",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Bharat Hydro Underground\nJal Analytics Network",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Dashboard Header
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "DASHBOARD",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Responsive Cards
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate card height dynamically
                        final availableHeight = constraints.maxHeight;
                        final cardHeight =
                            availableHeight / 3 - 20; // 3 cards + spacing

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildAnimatedCard(
                              DashboardCard(
                                icon: Icons.water_drop,
                                title: "Ground Water Data",
                                subtitle: "Explore levels, rainfall & more",
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const GroundWaterPage()),
                                ),
                                height: cardHeight,
                              ),
                              0,
                            ),
                            _buildAnimatedCard(
                              DashboardCard(
                                icon: Icons.compare_arrows,
                                title: "Comparison Dashboard",
                                subtitle: "Compare districts & blocks",
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const ComparisonSelectionPage()),
                                ),
                                height: cardHeight,
                              ),
                              1,
                            ),
                            _buildAnimatedCard(
                              DashboardCard(
                                icon: Icons.info_outline,
                                title: "General Information",
                                subtitle: "Learn more about the project",
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const InfoPage()),
                                ),
                                height: cardHeight,
                              ),
                              2,
                            ),
                          ],
                        );
                      },
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
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final double height; // ✅ make height configurable

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B054C), Color(0xFF1D2671)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(3, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
