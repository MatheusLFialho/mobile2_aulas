import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// =============================================================================
// AULA — NOTIFICACOES LOCAIS E PUSH (MVVM)
// =============================================================================
// Nesta aula usamos notificacao local de verdade (plugin) e um fluxo didatico
// de "push" simulado. O push real exige um provedor (ex.: FCM) e backend para
// envio. Aqui o foco e entender:
// 1) inicializacao do plugin;
// 2) permissao e exibicao de notificacao local;
// 3) tratamento de payload como se viesse de push remoto.
// =============================================================================

class AulaNotificacoesViewModel extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool inicializado = false;
  bool notificacaoPermissaoConcedida = false;
  String status = 'Ainda nao inicializado';
  String? ultimoTitulo;
  String? ultimoCorpo;
  String? ultimoPayload;

  Future<void> inicializar() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _processarPayload(
          titulo: 'Toque na notificacao',
          corpo: 'Usuario abriu a notificacao local',
          payload: response.payload ?? '{}',
        );
      },
    );

    // Android 13+: permissao de notificacao em runtime.
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await androidImpl?.requestNotificationsPermission() ?? false;

    // iOS/macOS: permissao explicita.
    final iosImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;

    notificacaoPermissaoConcedida = androidGranted || iosGranted || kIsWeb;
    inicializado = true;
    status = notificacaoPermissaoConcedida
        ? 'Plugin inicializado e permissao concedida'
        : 'Plugin inicializado, mas permissao negada/nao suportada';
    notifyListeners();
  }

  Future<void> enviarNotificacaoLocalExemplo() async {
    if (!inicializado) {
      status = 'Inicialize o plugin antes de enviar notificacao';
      notifyListeners();
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'aula_notificacoes_canal',
      'Aula Notificacoes',
      channelDescription: 'Canal de exemplos da aula de notificacoes',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = '{"origem":"local","tipo":"lembrete_aula"}';
    await _notificationsPlugin.show(
      id: 1001,
      title: 'Notificacao local',
      body: 'Este e um exemplo de notificacao local em Flutter.',
      notificationDetails: details,
      payload: payload,
    );

    status = 'Notificacao local enviada';
    _processarPayload(
      titulo: 'Notificacao local',
      corpo: 'Este e um exemplo de notificacao local em Flutter.',
      payload: payload,
    );
  }

  // Simula a chegada de uma notificacao push remota.
  // Em producao, este metodo seria chamado quando o app recebesse mensagem
  // de um provedor push (FCM/APNs/etc).
  Future<void> simularPushRemotoExemplo() async {
    const titulo = 'Push remoto (simulado)';
    const corpo = 'Oferta especial para quem esta estudando notificacoes!';
    const payload = '{"origem":"push","campanha":"aula_mobile_2"}';
    _processarPayload(titulo: titulo, corpo: corpo, payload: payload);

    // Em muitos apps, quando chega push com app em foreground, mostramos
    // uma notificacao local para o usuario perceber o evento.
    if (inicializado) {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'aula_notificacoes_canal',
          'Aula Notificacoes',
          channelDescription: 'Canal de exemplos da aula de notificacoes',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _notificationsPlugin.show(
        id: 1002,
        title: titulo,
        body: corpo,
        notificationDetails: details,
        payload: payload,
      );
    }
  }

  void _processarPayload({
    required String titulo,
    required String corpo,
    required String payload,
  }) {
    ultimoTitulo = titulo;
    ultimoCorpo = corpo;
    ultimoPayload = payload;
    status = 'Payload processado (local/push)';
    notifyListeners();
  }
}

