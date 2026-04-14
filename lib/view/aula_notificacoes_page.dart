import 'package:flutter/material.dart';

import '../viewmodel/aula_notificacoes_view_model.dart';

// =============================================================================
// AULA — NOTIFICACOES LOCAIS E PUSH (View em MVVM)
// =============================================================================
// Exemplo didatico simples:
// - Notificacao local real com flutter_local_notifications;
// - Push "simulado" para ensinar tratamento de payload sem depender de backend
//   nesta etapa da disciplina.
// =============================================================================

class AulaNotificacoesPage extends StatefulWidget {
  const AulaNotificacoesPage({super.key});

  @override
  State<AulaNotificacoesPage> createState() => _AulaNotificacoesPageState();
}

class _AulaNotificacoesPageState extends State<AulaNotificacoesPage> {
  final AulaNotificacoesViewModel _viewModel = AulaNotificacoesViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aula — Notificacoes locais e push'),
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
                      'Fluxo da aula',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1) Inicializar plugin e permissao\n'
                      '2) Enviar notificacao local\n'
                      '3) Simular push remoto e processar payload',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${_viewModel.status}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _viewModel.inicializar,
                  icon: const Icon(Icons.settings),
                  label: const Text('Inicializar'),
                ),
                ElevatedButton.icon(
                  onPressed: _viewModel.enviarNotificacaoLocalExemplo,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Local: Enviar exemplo'),
                ),
                ElevatedButton.icon(
                  onPressed: _viewModel.simularPushRemotoExemplo,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Push: Simular recebimento'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ultimo payload processado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Titulo: ${_viewModel.ultimoTitulo ?? '--'}'),
                    Text('Corpo: ${_viewModel.ultimoCorpo ?? '--'}'),
                    Text('Payload: ${_viewModel.ultimoPayload ?? '--'}'),
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
                      'Observacoes didaticas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '- Notificacao local e disparada pelo proprio app.\n'
                      '- Push remoto vem de um provedor (ex.: FCM/APNs) + backend.\n'
                      '- O tratamento de payload (navegar, atualizar estado) e '
                      'a parte mais importante para reaproveitar entre local e push.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

