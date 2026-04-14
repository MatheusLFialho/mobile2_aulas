import 'package:flutter/material.dart';

import '../viewmodel/app_view_model.dart';
import '../viewmodel/aula_acessibilidade_view_model.dart';
import 'aula1_contador_page.dart';
import 'aula_acessibilidade_page.dart';
import 'aula_entrada_permissoes_page.dart';
import 'aula_mapas_geolocalizacao_page.dart';
import 'aula_sensores_hardware_page.dart';
import 'aula_notificacoes_page.dart';

// =============================================================================
// MENU DE AULAS — View (MVVM)
// =============================================================================
// Tela inicial. Cada item abre uma aula (outra tela). Recebe o AppViewModel
// pra passar o estado do Raio-X e o callback pros filhos. Quando vocês
// chamam Navigator.push(), o Flutter empilha a nova tela; o botão "voltar"
// no AppBar dá pop() e volta pro menu.
// =============================================================================

class MenuPage extends StatelessWidget {
  const MenuPage({super.key, required this.appViewModel});

  final AppViewModel appViewModel;

  void _abrirAula(BuildContext context, Widget tela, String titulo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => tela,
        settings: RouteSettings(name: titulo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu de Aulas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              appViewModel.mostrarRaioX
                  ? Icons.accessibility
                  : Icons.accessibility_new,
            ),
            tooltip: appViewModel.mostrarRaioX
                ? 'Desligar Raio-X'
                : 'Ligar Raio-X',
            onPressed: () =>
                appViewModel.alternarRaioX(!appViewModel.mostrarRaioX),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Aula 1 — Contador'),
            subtitle: const Text(
              'Revisão Flutter: StatefulWidget, setState, layout',
            ),
            leading: const CircleAvatar(child: Icon(Icons.add_circle_outline)),
            onTap: () =>
                _abrirAula(context, const Aula1ContadorPage(), 'Aula 1'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Aula — Acessibilidade'),
            subtitle: const Text('Contraste 4,5:1, Semantics, Raio-X'),
            leading: const CircleAvatar(child: Icon(Icons.accessibility_new)),
            onTap: () => _abrirAula(
              context,
              AulaAcessibilidadePage(
                viewModel: AulaAcessibilidadeViewModel(
                  mostrarRaioX: appViewModel.mostrarRaioX,
                  aoAlternarRaioX: appViewModel.alternarRaioX,
                ),
              ),
              'Acessibilidade',
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Aula — Entrada e Permissões'),
            subtitle: const Text('Permissões de câmera e localização'),
            leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
            onTap: () => _abrirAula(
              context,
              const AulaEntradaPermissoesPage(),
              'Entrada e Permissões',
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Aula 1.5 — Mapas e geolocalização'),
            subtitle: const Text(
              'Flutter Web: mapa OSM, geolocator, marcador na posição',
            ),
            leading: const CircleAvatar(child: Icon(Icons.map)),
            onTap: () => _abrirAula(
              context,
              const AulaMapasGeolocalizacaoPage(),
              'Mapas e geolocalização',
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Aula 1.4 — Sensores de hardware'),
            subtitle: const Text('Acelerômetro, giroscópio e GPS'),
            leading: const CircleAvatar(child: Icon(Icons.sensors)),
            onTap: () => _abrirAula(
              context,
              const AulaSensoresHardwarePage(),
              'Sensores de hardware',
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Aula — Notificacoes locais e push'),
            subtitle: const Text('Exemplo simples com local + push simulado'),
            leading: const CircleAvatar(
              child: Icon(Icons.notifications_active),
            ),
            onTap: () => _abrirAula(
              context,
              const AulaNotificacoesPage(),
              'Notificacoes locais e push',
            ),
          ),
        ],
      ),
    );
  }
}
