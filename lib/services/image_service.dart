import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/cat_image.dart';

class ImageService {
  static const _historyKey = 'cat_history';
  static const _todayKey = 'cat_today';
  static const _offlinePoolKey = 'offline_pool';

  static Future<CatImage> getTodayCat() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = prefs.getString(_todayKey);
    final now = DateTime.now();
    if (todayStr != null) {
      final cached = CatImage.fromJson(jsonDecode(todayStr));
      if (isSameDay(cached.date, now)) {
        return cached;
      }
    }

    // Need a new one
    final url = await _fetchCatUrl();
    final cat = CatImage(url: url, date: now);
    await prefs.setString(_todayKey, jsonEncode(cat.toJson()));

    // Update history (last 7 days)
    final history = prefs.getStringList(_historyKey) ?? [];
    history.insert(0, jsonEncode(cat.toJson()));
    if (history.length > 7) history.removeLast();
    await prefs.setStringList(_historyKey, history);

    return cat;
  }

  static Future<List<CatImage>> getLast7Cats() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    return history.map((e) => CatImage.fromJson(jsonDecode(e))).toList();
  }

  static Future<String> _fetchCatUrl() async {
    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return _getOfflineCatUrl();
    }

    // 50/50 choose API
    final rnd = Random();
    if (rnd.nextBool()) {
      return 'https://cataas.com/cat?ts=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      final res = await http.get(Uri.parse('https://aws.random.cat/meow'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['file'];
      } else {
        return 'https://cataas.com/cat?ts=${DateTime.now().millisecondsSinceEpoch}';
      }
    }
  }

  static Future<void> preCacheOfflineCats(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final pool = prefs.getStringList(_offlinePoolKey) ?? [];
    while (pool.length < count) {
      final url = await _fetchCatUrl();
      pool.add(url);
    }
    await prefs.setStringList(_offlinePoolKey, pool);
  }

  static Future<String> _getOfflineCatUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final pool = prefs.getStringList(_offlinePoolKey) ?? [];
    if (pool.isNotEmpty) {
      final url = pool.removeAt(0);
      await prefs.setStringList(_offlinePoolKey, pool);
      return url;
    }
    // Fallback placeholder
    return 'https://cataas.com/cat';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
