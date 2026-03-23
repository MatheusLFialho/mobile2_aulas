import 'package:flutter/material.dart';

import '../viewmodel/aula_sensores_hardware_view_model.dart';

// =============================================================================
// AULA 1.4 — SENSORES DE HARDWARE (View em MVVM) — VERSÃO EXERCÍCIO
// =============================================================================
// Objetivo: ler acelerômetro, giroscópio e GPS na mesma tela.
// Partes essenciais da integração com ViewModel estão marcadas com TODO.
// =============================================================================

class AulaSensoresHardwarePage extends StatefulWidget {
  const AulaSensoresHardwarePage({super.key});

  @override
  State<AulaSensoresHardwarePage> createState() => _AulaSensoresHardwarePageState();
}

class _AulaSensoresHardwarePageState extends State<AulaSensoresHardwarePage> {
  final AulaSensoresHardwareViewModel _viewModel = AulaSensoresHardwareViewModel();

  @override
  void initState() {
    super.initState();
    // TODO: manter este padrão MVVM da disciplina:
    // _viewModel.addListener(_onViewModelChanged);
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    // TODO: remover listener para evitar memory leak.
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
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
                      'Acelerômetro (x, y, z)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // TODO: alunos podem melhorar a formatação com toStringAsFixed(2).
                    Text('x: ${_viewModel.ax}'),
                    Text('y: ${_viewModel.ay}'),
                    Text('z: ${_viewModel.az}'),
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
                      'Giroscópio (x, y, z)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // TODO: alunos podem melhorar a formatação com toStringAsFixed(2).
                    Text('x: ${_viewModel.gx}'),
                    Text('y: ${_viewModel.gy}'),
                    Text('z: ${_viewModel.gz}'),
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
                    Text('Latitude: ${_viewModel.latitude?.toStringAsFixed(6) ?? '--'}'),
                    Text('Longitude: ${_viewModel.longitude?.toStringAsFixed(6) ?? '--'}'),
                    Text('Precisão: ${_viewModel.precisao?.toStringAsFixed(2) ?? '--'} m'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_viewModel.mensagemErro != null)
              Text(
                _viewModel.mensagemErro!,
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
                  // TODO: ligar botão com iniciarMonitoramentoSensores().
                  onPressed: _viewModel.sensoresAtivos
                      ? null
                      : () => _viewModel.iniciarMonitoramentoSensores(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar sensores'),
                ),
                ElevatedButton.icon(
                  // TODO: ligar botão com pararMonitoramentoSensores().
                  onPressed: _viewModel.sensoresAtivos
                      ? () => _viewModel.pararMonitoramentoSensores()
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Parar sensores'),
                ),
                ElevatedButton.icon(
                  // TODO: ligar botão com obterLocalizacaoAtual() e tratar loading.
                  onPressed: _viewModel.gpsLoading
                      ? null
                      : () => _viewModel.obterLocalizacaoAtual(),
                  icon: _viewModel.gpsLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_viewModel.gpsLoading ? 'Lendo GPS...' : 'Ler GPS agora'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

