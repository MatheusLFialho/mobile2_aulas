import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../viewmodel/aula_mapas_geolocalizacao_view_model.dart';

// =============================================================================
// AULA 1.5 — INTEGRAÇÃO DE MAPAS E GEOLOCALIZAÇÃO (View em MVVM)
// =============================================================================
// Uma tela com mapa (OpenStreetMap) e um botão "Minha localização". No Flutter
// Web o navegador pede permissão de localização; no mobile seria o SO. O mapa
// usa o pacote flutter_map (tiles OSM) e o ViewModel usa geolocator para
// obter lat/lng. Rodem com: flutter run -d chrome
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
          // -------------------------------------------------------------------
          // MAPA — FlutterMap com tiles OpenStreetMap
          // -------------------------------------------------------------------
          // O initialCenter e initialZoom definem onde o mapa abre. Quando o
          // usuário obtém a localização, vamos centralizar no ViewModel com
          // _mapController.move(). O TileLayer usa os servidores públicos do
          // OSM; no web funciona sem API key.
          // -------------------------------------------------------------------
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
              // TODO: quando o ViewModel tiver posicaoAtual preenchida, exibir
              // um marcador no mapa. Use MarkerLayer(markers: [ Marker(point: ...,
              // child: Icon(Icons.location_on), width: 48, height: 48) ]).
              // Só mostre a camada de marcadores se posicao != null.
              if (posicao != null)
                MarkerLayer(
                  markers: [
                    // TODO: criar Marker com point: posicao e um Icon de localização
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
              // TODO: quando o ViewModel tiver pontosRota não vazio, desenhar a
              // rota no mapa. Use PolylineLayer(polylines: [ Polyline(
              //   points: viewModel.pontosRota, color: Colors.blue, strokeWidth: 4) ]).
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

          // -------------------------------------------------------------------
          // Rota até — dois pontos (origem = minha localização; destino = campos)
          // -------------------------------------------------------------------
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
                                // TODO: ler origem (posicaoAtual ?? centroInicialPadrao) e destino
                                // (parse _destinoLatController e _destinoLngController). Chamar
                                // _viewModel.buscarRota(origem, destino). Opcional: centralizar
                                // o mapa na rota (fitCamera ou move para o centro da rota).
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

          // -------------------------------------------------------------------
          // Botão flutuante "Minha localização"
          // -------------------------------------------------------------------
          // Ao tocar, deve chamar o ViewModel para obter a posição e depois
          // centralizar o mapa nela (MapController.move).
          // -------------------------------------------------------------------
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
                          // TODO: 1) Chamar await _viewModel.obterMinhaLocalizacao()
                          //       2) Se _viewModel.posicaoAtual != null, centralizar
                          //          o mapa: _mapController.move(posicaoAtual!, 15);
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
                // Card com coordenadas ou mensagem de erro (didático)
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
