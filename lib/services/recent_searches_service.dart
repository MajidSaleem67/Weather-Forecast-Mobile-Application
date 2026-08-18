import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesService {
  static const String _key = 'recent_cities';
  static const int _maxItems = 6;

  Future<List<String>> loadRecentCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  Future<List<String>> saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList(_key) ?? <String>[];

    cities.removeWhere((c) => c.toLowerCase() == city.toLowerCase());
    cities.insert(0, city);

    if (cities.length > _maxItems) {
      cities.removeRange(_maxItems, cities.length);
    }

    await prefs.setStringList(_key, cities);
    return cities;
  }

  Future<List<String>> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return <String>[];
  }
}
