import 'package:flutter/material.dart';
import 'services/api_services.dart';
import 'ComparisonPage.dart';

class ComparisonSelectionPage extends StatefulWidget {
  const ComparisonSelectionPage({super.key});

  @override
  State<ComparisonSelectionPage> createState() =>
      _ComparisonSelectionPageState();
}

class _ComparisonSelectionPageState extends State<ComparisonSelectionPage> {
  List<String> _districts = [];
  List<String> _blocks = [];
  String? _selectedDistrict;
  String? _selectedBlock;

  final List<Map<String, String>> _selectedPairs = [];
  bool _loadingDistricts = true;
  bool _loadingBlocks = false;

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
  }

  Future<void> _fetchDistricts() async {
    try {
      final districts = await ApiService.getDistricts();
      setState(() {
        _districts = districts;
        _loadingDistricts = false;
      });
    } catch (e) {
      debugPrint("❌ Failed to fetch districts: $e");
      setState(() => _loadingDistricts = false);
    }
  }

  Future<void> _fetchBlocks(String district) async {
    setState(() {
      _loadingBlocks = true;
      _blocks = [];
      _selectedBlock = null;
    });

    try {
      final blocks = await ApiService.getBlocks(district);
      setState(() {
        _blocks = blocks;
        _loadingBlocks = false;
      });
    } catch (e) {
      debugPrint("❌ Failed to fetch blocks: $e");
      setState(() => _loadingBlocks = false);
    }
  }

  void _addPair() {
    if (_selectedDistrict != null && _selectedBlock != null) {
      final newPair = {
        "district": _selectedDistrict!,
        "block": _selectedBlock!,
      };

      // ✅ Prevent duplicates
      if (!_selectedPairs.contains(newPair)) {
        setState(() => _selectedPairs.add(newPair));
      }
    }
  }

  void _removePair(int index) {
    setState(() {
      _selectedPairs.removeAt(index);
    });
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: isLoading
          ? const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      )
          : DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label),
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((e) =>
              DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
        ),
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
          Container(color: Colors.black.withOpacity(0.3)),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset("assets/cgwb_logo.png", width: 100, height: 140),
                const SizedBox(height: 10),
                const Text(
                  "Comparison Dashboard",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                // District dropdown
                _buildDropdown(
                  label: "Select District",
                  value: _selectedDistrict,
                  items: _districts,
                  isLoading: _loadingDistricts,
                  onChanged: (val) {
                    setState(() => _selectedDistrict = val);
                    if (val != null) _fetchBlocks(val);
                  },
                ),

                // Block dropdown
                _buildDropdown(
                  label: "Select Block",
                  value: _selectedBlock,
                  items: _blocks,
                  isLoading: _loadingBlocks,
                  onChanged: (val) => setState(() => _selectedBlock = val),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _addPair,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Location"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),

                // Selected Pairs
                if (_selectedPairs.isNotEmpty)
                  Column(
                    children: _selectedPairs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pair = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text("${pair['district']} - ${pair['block']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removePair(index),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _selectedPairs.isEmpty
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComparisonPage(
                            selectedPairs: _selectedPairs),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Compare"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
