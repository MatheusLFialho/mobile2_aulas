import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

// =============================================================================
// AULA 1.4 — SENSORES DE HARDWARE (MVVM)
// =============================================================================
// Acelerômetro e giroscópio em tempo real (streams) e GPS sob demanda
// (Geolocator). Em muitos navegadores os sensores de movimento não estão
// disponíveis no Flutter Web — use dispositivo/emulador Android para testar.
// =============================================================================

class AulaSensoresHardwareViewModel extends ChangeNotifier {
  // Leituras do acelerômetro (m/s²) e giroscópio (rad/s).
  double ax = 0;
  double ay = 0;
  double az = 0;
  double gx = 0;
  double gy = 0;
  double gz = 0;

  // GPS: latitude, longitude e precisão em metros.
  double? latitude;
  double? longitude;
  double? precisao;

  bool sensoresAtivos = false;
  bool gpsLoading = false;
  String? mensagemErro;

  StreamSubscription<UserAccelerometerEvent>? _accSub;
  StreamSubscription<GyroscopeEvent>? _gyrSub;

  Future<void> iniciarMonitoramentoSensores() async {
    await _accSub?.cancel();
    await _gyrSub?.cancel();
    _accSub = null;
    _gyrSub = null;

    try {
      _accSub = userAccelerometerEventStream().listen(
        (UserAccelerometerEvent e) {
          ax = e.x;
          ay = e.y;
          az = e.z;
          notifyListeners();
        },
        onError: (Object e) {
          mensagemErro = 'Acelerômetro: $e';
          notifyListeners();
        },
      );
      _gyrSub = gyroscopeEventStream().listen(
        (GyroscopeEvent e) {
          gx = e.x;
          gy = e.y;
          gz = e.z;
          notifyListeners();
        },
        onError: (Object e) {
          mensagemErro = 'Giroscópio: $e';
          notifyListeners();
        },
      );
      sensoresAtivos = true;
      mensagemErro = null;
    } catch (e) {
      sensoresAtivos = false;
      mensagemErro =
          'Não foi possível iniciar os sensores (Web/emulador pode não suportar): $e';
    }
    notifyListeners();
  }

  Future<void> pararMonitoramentoSensores() async {
    await _accSub?.cancel();
    await _gyrSub?.cancel();
    _accSub = null;
    _gyrSub = null;
    sensoresAtivos = false;
    notifyListeners();
  }

  Future<void> obterLocalizacaoAtual() async {
    gpsLoading = true;
    mensagemErro = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        mensagemErro = 'Serviço de localização desligado';
        gpsLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        mensagemErro = 'Permissão de localização negada permanentemente';
        gpsLoading = false;
        notifyListeners();
        return;
      }
      if (permission == LocationPermission.denied) {
        mensagemErro = 'Permissão de localização negada';
        gpsLoading = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
      precisao = position.accuracy;
    } catch (e) {
      mensagemErro = 'Erro ao obter GPS: $e';
    }

    gpsLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _gyrSub?.cancel();
    super.dispose();
  }
}
