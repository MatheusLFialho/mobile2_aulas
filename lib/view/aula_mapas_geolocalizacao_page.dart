import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../viewmodel/aula_mapas_geolocalizacao_view_model.dart';

// =============================================================================
// AULA 1.5 — MAPAS E GEOLOCALIZAÇÃO (View em MVVM)
// =============================================================================
// Mapa OSM, botão "Minha localização", rota entre dois pontos (OSRM).
// No Flutter Web o navegador pede permissão de localização.
// =============================================================================

class AulaMapasGeolocalizacaoPage extends StatefulWidget {
  const AulaMapasGeolocalizacaoPage({super.key});

  @override
  State<AulaMapasGeolocalizacaoPage> createState() =>
      _AulaMapasGeolocalizacaoPageState();
}

class _AulaMapasGeolocalizacaoPageState
    extends State<AulaMapasGeolocalizacaoPage> {
  final AulaMapasGeolocalizacaoViewModel _viewModel =
      AulaMapasGeolocalizacaoViewModel();
  final MapController _mapController = MapController();
  final TextEditingController _destinoLatController = TextEditingController(text: '-23.5489');
  final TextEditingController _destinoLngController = TextEditingController(text: '-46.6388');

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _mapController.dispose();
    _destinoLatController.dispose();
    _destinoLngController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final posicao = _viewModel.posicaoAtual;
    final loading = _viewModel.loading;
    final erro = _viewModel.mensagemErro;
    final pontosRota = _viewModel.pontosRota;
    final rotaLoading = _viewModel.rotaLoading;
    final rotaErro = _viewModel.rotaErro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapas e geolocalização'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: AulaMapasGeolocalizacaoViewModel.centroInicialPadrao,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile2_aulas',
              ),
              if (posicao != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: posicao,
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red.shade700,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              if (pontosRota.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: pontosRota,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 16,
            top: 16,
            right: 100,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rota até',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Origem: use "Minha localização" antes, ou será o centro padrão.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _destinoLatController,
                            decoration: const InputDecoration(
                              labelText: 'Destino Lat',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _destinoLngController,
                            decoration: const InputDecoration(
                              labelText: 'Destino Lng',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    if (rotaErro != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          rotaErro,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade700,
                              ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: rotaLoading
                            ? null
                            : () async {
                                final lat = double.tryParse(_destinoLatController.text);
                                final lng = double.tryParse(_destinoLngController.text);
                                if (lat == null || lng == null) return;
                                final origem = posicao ?? AulaMapasGeolocalizacaoViewModel.centroInicialPadrao;
                                final destino = LatLng(lat, lng);
                                await _viewModel.buscarRota(origem, destino);
                                if (_viewModel.pontosRota.isNotEmpty) {
                                  _mapController.move(origem, 12);
                                }
                              },
                        icon: rotaLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.route),
                        label: Text(rotaLoading ? 'Buscando...' : 'Rota até'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: loading
                      ? null
                      : () async {
                          await _viewModel.obterMinhaLocalizacao();
                          final p = _viewModel.posicaoAtual;
                          if (p != null) _mapController.move(p, 15);
                        },
                  icon: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(loading ? 'Obtendo...' : 'Minha localização'),
                ),
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (erro != null)
                          Text(
                            erro,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.red.shade700),
                          )
                        else if (posicao != null)
                          Text(
                            'Lat: ${posicao.latitude.toStringAsFixed(5)}\n'
                            'Lng: ${posicao.longitude.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        else
                          Text(
                            'Toque em "Minha localização" para obter sua posição.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
