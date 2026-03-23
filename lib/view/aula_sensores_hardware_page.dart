import 'package:flutter/material.dart';

import '../viewmodel/aula_sensores_hardware_view_model.dart';

// =============================================================================
// AULA 1.4 — SENSORES DE HARDWARE (View em MVVM)
// =============================================================================
// Exibe leituras de acelerômetro, giroscópio e GPS. O ViewModel gerencia
// streams e permissões; a View apenas reage ao estado (addListener + setState).
// =============================================================================

class AulaSensoresHardwarePage extends StatefulWidget {
  const AulaSensoresHardwarePage({super.key});

  @override
  State<AulaSensoresHardwarePage> createState() =>
      _AulaSensoresHardwarePageState();
}

class _AulaSensoresHardwarePageState extends State<AulaSensoresHardwarePage> {
  final AulaSensoresHardwareViewModel _viewModel =
      AulaSensoresHardwareViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aula 1.4 — Sensores de hardware'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acelerômetro (x, y, z) — m/s²',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('x: ${vm.ax.toStringAsFixed(2)}'),
                    Text('y: ${vm.ay.toStringAsFixed(2)}'),
                    Text('z: ${vm.az.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giroscópio (x, y, z) — rad/s',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('x: ${vm.gx.toStringAsFixed(2)}'),
                    Text('y: ${vm.gy.toStringAsFixed(2)}'),
                    Text('z: ${vm.gz.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS (latitude, longitude, precisão)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: ${vm.latitude?.toStringAsFixed(6) ?? '--'}',
                    ),
                    Text(
                      'Longitude: ${vm.longitude?.toStringAsFixed(6) ?? '--'}',
                    ),
                    Text(
                      'Precisão: ${vm.precisao?.toStringAsFixed(2) ?? '--'} m',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (vm.mensagemErro != null)
              Text(
                vm.mensagemErro!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                    ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: vm.sensoresAtivos
                      ? null
                      : () => vm.iniciarMonitoramentoSensores(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar sensores'),
                ),
                ElevatedButton.icon(
                  onPressed: vm.sensoresAtivos
                      ? () => vm.pararMonitoramentoSensores()
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Parar sensores'),
                ),
                ElevatedButton.icon(
                  onPressed: vm.gpsLoading
                      ? null
                      : () => vm.obterLocalizacaoAtual(),
                  icon: vm.gpsLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(vm.gpsLoading ? 'Lendo GPS...' : 'Ler GPS agora'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
