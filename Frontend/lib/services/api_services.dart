import 'dart:convert';
import 'dart:async'; // 👈 needed for TimeoutException
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.15:8000";


  // 🔹 Helper: make GET request with timeout + error handling
  static Future<http.Response> _get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8)); // ⏳ prevent hanging
      return response;
    } on TimeoutException {
      throw Exception("Request to $url timed out. Please try again.");
    } catch (e) {
      throw Exception("Failed request to $url: $e");
    }
  }

  // -------------------------------
  // Districts & Blocks
  // -------------------------------

  /// 🔹 Get all districts (list of names)
  static Future<List<String>> getDistricts() async {
    final response = await _get("$baseUrl/districts");
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((e) => e.toString()).toList();
      }
    }
    throw Exception("Failed to load districts");
  }

  /// 🔹 Get all blocks for a district
  static Future<List<String>> getBlocks(String district) async {
    final uri = Uri.parse("$baseUrl/blocks")
        .replace(queryParameters: {"district": district});
    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((e) => e.toString()).toList();
      }
    }
    throw Exception("Failed to load blocks for $district");
  }

  /// 🔹 Get district name if you only have block
  static Future<String?> getDistrictByBlock(String block) async {
    final uri = Uri.parse("$baseUrl/district-by-block")
        .replace(queryParameters: {"block": block});
    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["district"];
    }
    return null;
  }

  /// 🔹 Get all blocks with their district (Map<Block → District>)
  static Future<Map<String, String>> getAllBlocks() async {
    final response = await _get("$baseUrl/blocks-all");
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    throw Exception("Failed to load all blocks");
  }

  // -------------------------------
  // Analytics / Metrics
  // -------------------------------

  /// 🔹 Get plot of last 10 days mean levels
  static Future<String?> getPlotMeanLevels(
      String district, String block) async {
    final uri = Uri.parse("$baseUrl/plot-mean-levels").replace(queryParameters: {
      "district": district,
      "block": block,
      "days": "10"
    });
    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["plot_base64"];
    }
    return null;
  }

  /// 🔹 Fetch all extra stats (last date, rainfall, aquifer, score, etc.)
  static Future<Map<String, dynamic>> getExtras(
      String district, String block) async {
    final uri = Uri.parse("$baseUrl/extras")
        .replace(queryParameters: {"district": district, "block": block});
    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load extras");
  }

  /// 🔹 Get daily fluctuation (difference of last 2 days mean levels)
  static Future<Map<String, dynamic>?> getDailyFluctuation(
      String district, String block) async {
    final uri = Uri.parse("$baseUrl/fluctuations-daily")
        .replace(queryParameters: {"district": district, "block": block});
    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      return null; // no fluctuation data
    }
    throw Exception("Failed to load daily fluctuation");
  }
}
