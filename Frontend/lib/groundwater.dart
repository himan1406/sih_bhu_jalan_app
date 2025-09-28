import 'dart:async';
import 'package:flutter/material.dart';
import 'services/api_services.dart';
import 'AnalyticsPage.dart';

class GroundWaterPage extends StatefulWidget {
  const GroundWaterPage({super.key});

  @override
  State<GroundWaterPage> createState() => _GroundWaterPageState();
}

class _GroundWaterPageState extends State<GroundWaterPage> {
  final String _state = "Uttar Pradesh";
  List<String> _districts = [];
  List<String> _blocks = [];

  String? _selectedDistrict;
  String? _selectedBlock;

  bool _loadingDistricts = true;
  bool _loadingBlocks = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
  }

  Future<void> _fetchDistricts() async {
    setState(() {
      _loadingDistricts = true;
      _errorMsg = null;
    });

    try {
      final districts =
      await ApiService.getDistricts().timeout(const Duration(seconds: 10));
      setState(() {
        _districts = districts;
        _loadingDistricts = false;
      });
    } on TimeoutException {
      setState(() {
        _loadingDistricts = false;
        _errorMsg = "⚠️ Request timed out. Please retry.";
      });
    } catch (e) {
      setState(() {
        _districts = [];
        _loadingDistricts = false;
        _errorMsg = "❌ Could not load districts: $e";
      });
    }
  }

  Future<void> _fetchBlocks(String district) async {
    setState(() {
      _loadingBlocks = true;
      _blocks = [];
      _selectedBlock = null;
      _errorMsg = null;
    });

    try {
      final blocks =
      await ApiService.getBlocks(district).timeout(const Duration(seconds: 10));
      setState(() {
        _blocks = blocks;
        _loadingBlocks = false;
      });
    } on TimeoutException {
      setState(() {
        _loadingBlocks = false;
        _errorMsg = "⚠️ Block request timed out.";
      });
    } catch (e) {
      setState(() {
        _loadingBlocks = false;
        _errorMsg = "❌ Could not load blocks: $e";
      });
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label),
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (val) {
            if (items.isNotEmpty) {
              onChanged(val);
            }
          },
          items: items.isEmpty
              ? [
            const DropdownMenuItem(
              value: null,
              child: Text("No options available",
                  style: TextStyle(color: Colors.grey)),
            )
          ]
              : items
              .map((e) => DropdownMenuItem<String>(
            value: e,
            child: Text(
              e,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ))
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
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Logo
                Image.asset("assets/cgwb_logo.png", width: 100, height: 140),
                const SizedBox(height: 20),

                const Text(
                  "Groundwater Data",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // State
                _buildDropdown(
                  label: "Select State",
                  value: _state,
                  items: [_state],
                  onChanged: (_) {},
                ),

                // Districts with error handling
                if (_errorMsg != null)
                  Column(
                    children: [
                      Text(_errorMsg!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchDistricts,
                        child: const Text("Retry"),
                      ),
                    ],
                  )
                else
                  _buildDropdown(
                    label: "Select District",
                    value: _selectedDistrict,
                    items: _districts,
                    isLoading: _loadingDistricts,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedDistrict = value);
                        _fetchBlocks(value);
                      }
                    },
                  ),

                // Blocks
                _buildDropdown(
                  label: "Select Block",
                  value: _selectedBlock,
                  items: _blocks,
                  isLoading: _loadingBlocks,
                  onChanged: (value) {
                    setState(() => _selectedBlock = value);
                  },
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedDistrict != null && _selectedBlock != null
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnalyticsPage(
                          district: _selectedDistrict!,
                          block: _selectedBlock!,
                        ),
                      ),
                    );
                  }
                      : null,
                  child: const Text("Get Data",
                      style: TextStyle(fontSize: 18)),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
