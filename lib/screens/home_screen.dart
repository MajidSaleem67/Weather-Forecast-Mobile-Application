import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/recent_searches_service.dart';
import '../services/weather_service.dart';
import '../widgets/recent_searches.dart';
import '../widgets/weather_display.dart';

enum ViewState { initial, loading, data, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _weatherService = WeatherService();
  final _recentService = RecentSearchesService();

  ViewState _state = ViewState.initial;
  Weather? _weather;
  String _errorMessage = '';
  List<String> _recentCities = [];

  @override
  void initState() {
    super.initState();
    _loadRecentCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentCities() async {
    final cities = await _recentService.loadRecentCities();
    if (mounted) setState(() => _recentCities = cities);
  }

  Future<void> _search(String city) async {
    if (city.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _state = ViewState.loading;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.fetchWeatherByCity(city);
      final updated = await _recentService.saveCity(weather.cityName);
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _recentCities = updated;
        _state = ViewState.data;
      });
    } on WeatherException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _state = ViewState.error;
      });
    }
  }

  Future<void> _clearRecentCities() async {
    final cleared = await _recentService.clearAll();
    if (mounted) setState(() => _recentCities = cleared);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F3B63), Color(0xFF4A90D9), Color(0xFF87BDE8)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Weather Forecast',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    if (_recentCities.isNotEmpty)
                      RecentSearches(
                        cities: _recentCities,
                        onCityTap: (city) {
                          _searchController.text = city;
                          _search(city);
                        },
                        onClear: _clearRecentCities,
                      ),
                    const SizedBox(height: 16),
                    _buildBody(constraints),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: _search,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search city (e.g. London)',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: const Icon(Icons.location_city, color: Colors.white70),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _search(_searchController.text),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildBody(BoxConstraints constraints) {
    switch (_state) {
      case ViewState.loading:
        return SizedBox(
          height: constraints.maxHeight * 0.5,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      case ViewState.error:
        return _ErrorCard(
          message: _errorMessage,
          onRetry: () => _search(_searchController.text),
        );
      case ViewState.data:
        return WeatherDisplay(weather: _weather!);
      case ViewState.initial:
        return SizedBox(
          height: constraints.maxHeight * 0.5,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_outlined,
                    size: 72, color: Colors.white.withOpacity(0.7)),
                const SizedBox(height: 12),
                Text(
                  'Search for a city to see the weather',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
