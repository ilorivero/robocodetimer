import 'dart:async';
import 'package:flutter/material.dart';

/// Ponto de entrada principal da aplicação Flutter.
void main() {
  runApp(const CountdownApp());
}

/// O widget raiz da aplicação.
///
/// É um [StatefulWidget] para poder gerenciar o estado do tema (claro/escuro)
/// e passá-lo para os widgets filhos.
class CountdownApp extends StatefulWidget {
  const CountdownApp({super.key});

  @override
  State<CountdownApp> createState() => _CountdownAppState();
}

class _CountdownAppState extends State<CountdownApp> {
  /// Controla o modo de tema atual da aplicação (claro ou escuro).
  ThemeMode _themeMode = ThemeMode.dark;

  /// Alterna o tema entre claro e escuro e reconstrói o widget.
  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maratona Robocode',
      debugShowCheckedModeBanner: false,

      // Define o tema para o modo claro.
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      // Define o tema para o modo escuro.
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      // Aplica o tema com base na variável de estado `_themeMode`.
      themeMode: _themeMode,

      // A tela principal do aplicativo, que recebe a função de alterar o tema.
      home: CountdownScreen(
        onThemeChanged: _toggleTheme,
        currentTheme: _themeMode,
      ),
    );
  }
}

/// A tela principal que exibe o cronômetro e os controles.
class CountdownScreen extends StatefulWidget {
  /// Callback recebido do widget pai para alterar o tema.
  final VoidCallback onThemeChanged;

  /// O modo de tema atual, recebido do widget pai.
  final ThemeMode currentTheme;

  const CountdownScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  /// Duração inicial do cronômetro (configurado para 2 horas).
  static const _initialDuration = Duration(hours: 2);

  // --- Variáveis de Estado ---
  /// A duração atual da contagem regressiva.
  Duration _duration = _initialDuration;

  /// O timer principal que decrementa a duração a cada segundo.
  Timer? _timer;

  /// O timer secundário que controla os efeitos de piscar (blink).
  Timer? _blinkTimer;

  /// Estado booleano para controlar se o texto está no ciclo "piscar".
  bool _isBlinking = false;

  /// Estado booleano para controlar se o cronômetro está rodando.
  bool _isRunning = false;

  /// Método do ciclo de vida chamado quando o widget é removido da árvore.
  /// Essencial para cancelar os timers e evitar vazamentos de memória.
  @override
  void dispose() {
    _timer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  // --- Lógica do Cronômetro ---

  /// Inicia o cronômetro, se ele não estiver rodando.
  void _startTimer() {
    if (_isRunning || _duration.inSeconds == 0) return;
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_duration.inSeconds > 0) {
        setState(() {
          _duration = Duration(seconds: _duration.inSeconds - 1);
          // A cada segundo, verifica se algum alerta visual deve ser ativado.
          _checkTimeForAlerts();
        });
      } else {
        _stopTimer(reset: false); // Para o timer quando chega a zero.
      }
    });
  }

  /// Para o cronômetro e, opcionalmente, o reseta para o valor inicial.
  void _stopTimer({bool reset = true}) {
    _timer?.cancel();
    _blinkTimer?.cancel(); // Também para qualquer efeito de piscar.
    setState(() {
      _isRunning = false;
      _isBlinking = false; // Reseta o estado de piscar.
      if (reset) _duration = _initialDuration;
    });
  }

  /// Pausa o cronômetro no tempo atual.
  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  // --- Lógica de Alertas Visuais ---

  /// Verifica o tempo atual e dispara os alertas visuais correspondentes.
  void _checkTimeForAlerts() {
    final seconds = _duration.inSeconds;

    // Alerta 1: Faltam 5 minutos ou menos (300 segundos).
    if (seconds <= 300) {
      if (_blinkTimer == null || !_blinkTimer!.isActive) {
        _startContinuousBlink();
      }
    }
    // Alerta 2: Atingiu marcos de 30 minutos (1h30, 1h00, 0h30).
    else if (seconds == 5400 || seconds == 3600 || seconds == 1800) {
      _triggerTemporaryBlink();
    }
  }

  /// Inicia um efeito de piscar contínuo, usado nos últimos 5 minutos.
  void _startContinuousBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  /// Dispara um efeito de piscar temporário que se cancela sozinho.
  void _triggerTemporaryBlink() {
    int blinkCount = 0;
    const int maxBlinks = 6; // Pisca 3 vezes (liga/desliga) por ~2.4 segundos.

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _isBlinking = !_isBlinking;
      });
      blinkCount++;
      if (blinkCount >= maxBlinks) {
        timer.cancel();
        setState(() {
          // Garante que o texto termine visível (não piscando).
          _isBlinking = false;
        });
      }
    });
  }

  // --- Funções de UI (Helpers) ---

  /// Formata um objeto [Duration] para uma string no formato HH:MM:SS.
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  /// Determina a cor do texto do cronômetro com base nas regras de alerta.
  Color _getTimerColor(bool isDarkMode) {
    final bool isUnder5Min =
        _duration.inSeconds <= 300 && _duration.inSeconds > 0;
    final defaultGreen = isDarkMode
        ? const Color(0xFF00FF00)
        : const Color.fromARGB(255, 3, 85, 3);

    if (isUnder5Min) {
      // Nos últimos 5 minutos, alterna entre vermelho e transparente.
      return _isBlinking ? Colors.red : Colors.transparent;
    } else {
      // Nos alertas temporários, alterna entre vermelho e a cor verde padrão.
      return _isBlinking ? Colors.red : defaultGreen;
    }
  }

  /// Constrói a interface gráfica do widget.
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = widget.currentTheme == ThemeMode.dark;

    return Scaffold(
      // Stack é usado para permitir a sobreposição do botão de tema.
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- Seção do Cabeçalho ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/logorobochallenge.png', height: 250),
                    Text(
                      'Maratona Robocode',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Image.asset('assets/logoiceipucminas.png', height: 200),
                  ],
                ),

                // --- Seção do Cronômetro ---
                Expanded(
                  child: Center(
                    // FittedBox garante que o texto ocupe toda a largura disponível.
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontWeight: FontWeight.w700,
                          // A cor é definida dinamicamente pela função helper.
                          color: _getTimerColor(isDarkMode),
                          // O tamanho da fonte é responsivo à altura da tela.
                          fontSize: screenHeight * 0.75,
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Seção dos Botões de Controle ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isRunning ? 'Pausar' : 'Iniciar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton.icon(
                      onPressed: () => _stopTimer(reset: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Resetar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- Seção do Rodapé ---
                const Text(
                  'Robochallenge 2025 PUC Minas',
                  style: TextStyle(fontSize: 40, color: Colors.grey),
                ),
              ],
            ),
          ),

          // --- Botão Flutuante para Mudar o Tema ---
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                iconSize: 30,
                tooltip: 'Mudar Tema',
                onPressed: widget.onThemeChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
