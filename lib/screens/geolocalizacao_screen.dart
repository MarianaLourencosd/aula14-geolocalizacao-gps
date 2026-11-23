import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class GeolocalizacaoScreen extends StatefulWidget {
  const GeolocalizacaoScreen({super.key});

  @override
  State<GeolocalizacaoScreen> createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen> {
  final _locationService = LocationService();
  Position? _posicaoAtual;
  bool _carregando = false;
  String? _mensagemErro;
  StreamSubscription<Position>? _positionStreamSub;
  bool _rastreando = false;

  static const double _fatecLat = -21.6033;
  static const double _fatecLng = -48.3658;

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final posicao = await _locationService.obterPosicaoAtual();
      setState(() => _posicaoAtual = posicao);
    } catch (e) {
      setState(() =>
          _mensagemErro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _alternarRastreamento() {
    if (_rastreando) {
      _positionStreamSub?.cancel();
      setState(() => _rastreando = false);
    } else {
      setState(() => _rastreando = true);
      _positionStreamSub = _locationService.monitorarPosicao().listen(
            (pos) => setState(() => _posicaoAtual = pos),
            onError: (err) => setState(() => _mensagemErro = err.toString()),
          );
    }
  }

  Color _corPrecisao(double acc) {
    if (acc < 15) return Colors.green;
    if (acc <= 50) return Colors.amber;
    return Colors.red;
  }

  String _textoPrecisao(double acc) {
    if (acc < 15) return 'Alta';
    if (acc <= 50) return 'Média';
    return 'Baixa';
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distancia = _posicaoAtual != null
        ? Geolocator.distanceBetween(
            _posicaoAtual!.latitude,
            _posicaoAtual!.longitude,
            _fatecLat,
            _fatecLng,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in & GPS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_carregando) const CircularProgressIndicator(),
            if (_mensagemErro != null)
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _mensagemErro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            if (_posicaoAtual != null) ...[
              Card(
                elevation: 3,
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.my_location, color: Colors.blue),
                      title: const Text('Latitude'),
                      subtitle: Text('${_posicaoAtual!.latitude}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on,
                          color: Colors.green),
                      title: const Text('Longitude'),
                      subtitle: Text('${_posicaoAtual!.longitude}'),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.speed, color: Colors.orange),
                      title: const Text('Precisão / Altitude'),
                      subtitle: Text(
                        'Precisão: ${_posicaoAtual!.accuracy.toStringAsFixed(1)}m | '
                        'Alt: ${_posicaoAtual!.altitude.toStringAsFixed(1)}m',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  avatar: const Icon(
                    Icons.gps_fixed,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: _corPrecisao(_posicaoAtual!.accuracy),
                  label: Text(
                    'Precisão ${_textoPrecisao(_posicaoAtual!.accuracy)}: '
                    '${_posicaoAtual!.accuracy.toStringAsFixed(1)} m',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (distancia != null)
                Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    leading:
                        const Icon(Icons.school, color: Colors.purple),
                    title: const Text('Distância até a Fatec Matão'),
                    subtitle: Text(
                      distancia < 1000
                          ? '${distancia.toStringAsFixed(1)} m'
                          : '${(distancia / 1000).toStringAsFixed(2)} km',
                    ),
                  ),
                ),
            ],
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _buscarLocalizacao,
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Capturar Localização Atual'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _alternarRastreamento,
              icon: Icon(_rastreando ? Icons.stop : Icons.play_arrow),
              label: Text(
                _rastreando
                    ? 'Parar Rastreamento'
                    : 'Iniciar Rastreamento Contínuo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
