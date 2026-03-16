import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// =============================================================================
// AULA 1.5 — MAPAS E GEOLOCALIZAÇÃO — VIEW MODEL (MVVM)
// =============================================================================
// Guarda posição atual, estado de loading/erro e pontos da rota (OSRM).
// obterMinhaLocalizacao() usa Geolocator; buscarRota() chama a API OSRM.
// =============================================================================

class AulaMapasGeolocalizacaoViewModel extends ChangeNotifier {
  static const LatLng centroInicialPadrao = LatLng(-23.5505, -46.6333);

  LatLng? _posicaoAtual;
  bool _loading = false;
  String? _mensagemErro;

  List<LatLng> _pontosRota = [];
  bool _rotaLoading = false;
  String? _rotaErro;

  LatLng? get posicaoAtual => _posicaoAtual;
  bool get loading => _loading;
  String? get mensagemErro => _mensagemErro;
  List<LatLng> get pontosRota => _pontosRota;
  bool get rotaLoading => _rotaLoading;
  String? get rotaErro => _rotaErro;

  Future<void> obterMinhaLocalizacao() async {
    _loading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mensagemErro = 'Serviço de localização desligado';
        _loading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _mensagemErro = 'Permissão negada permanentemente';
        _loading = false;
        notifyListeners();
        return;
      }
      if (permission == LocationPermission.denied) {
        _mensagemErro = 'Permissão negada';
        _loading = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _posicaoAtual = LatLng(position.latitude, position.longitude);
    } catch (e) {
      _mensagemErro = 'Erro: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> buscarRota(LatLng origem, LatLng destino) async {
    _rotaLoading = true;
    _rotaErro = null;
    _pontosRota = [];
    notifyListeners();

    try {
      final lng1 = origem.longitude;
      final lat1 = origem.latitude;
      final lng2 = destino.longitude;
      final lat2 = destino.latitude;
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$lng1,$lat1;$lng2,$lat2?overview=full&geometries=geojson',
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        _rotaErro = 'OSRM retornou ${response.statusCode}';
        _rotaLoading = false;
        notifyListeners();
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        _rotaErro = 'Nenhuma rota encontrada';
        _rotaLoading = false;
        notifyListeners();
        return;
      }

      final geometry = routes[0]['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.isEmpty) {
        _rotaErro = 'Geometria da rota vazia';
        _rotaLoading = false;
        notifyListeners();
        return;
      }

      _pontosRota = coords.map((c) {
        final list = c as List<dynamic>;
        final lng = (list[0] as num).toDouble();
        final lat = (list[1] as num).toDouble();
        return LatLng(lat, lng);
      }).toList();
    } catch (e) {
      _rotaErro = 'Erro: $e';
    }

    _rotaLoading = false;
    notifyListeners();
  }
}
