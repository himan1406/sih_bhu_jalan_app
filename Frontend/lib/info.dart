import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Background
          Image.asset("assets/cgwb_bg.png", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 🔹 Logo + Title
                Image.asset("assets/cgwb_logo.png", width: 100, height: 140),
                const SizedBox(height: 12),
                const Text(
                  "BHU-JALAN",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Central Ground Water Board",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "General Information",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Info Cards
                _buildInfoCard(
                  title: "📊 Groundwater Sustainability Scoring System",
                  content: '''
The groundwater sustainability **score** is calculated by combining multiple weighted factors that reflect both **quantity** and **quality** of groundwater.

---

### 🔹 Factors considered:
• **Water Level Trend (30%)**  
   Indicates whether water levels are rising, stable, or declining.

• **Rainfall Contribution (20%)**  
   Recharge potential from rainfall.

• **Specific Yield (15%)**  
   The aquifer’s capacity to release groundwater.

• **Water Quality (20%)**  
   pH, EC, Chlorides, Fluoride, and Hardness — compared against standards.

• **Aquifer Type (15%)**  
   Alluvial aquifers recharge faster than hard rock aquifers.

---

### 🔹 Interpretation:
✅ **> 75% → Sustainable**  
⚠️ **50–75% → Moderate**  
❌ **< 50% → Critical**
''',
                ),

                // 🔹 Future cards can be added here
                // _buildInfoCard(title: "About Aquifers", content: "...")
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E3F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          trailing: const Icon(Icons.expand_more, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
