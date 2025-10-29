import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importado para os formatadores de texto

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
  // Alterado para 'light' como padrão, conforme solicitado.
  ThemeMode _themeMode = ThemeMode.light;

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
      title: 'Timer Robochallenge', // Título genérico
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
  // --- Variáveis de Estado ---

  /// Duração inicial configurável do cronômetro.
  Duration _initialDuration = const Duration(hours: 2);

  /// Nome da modalidade atual.
  String _modalityName = 'Maratona Robocode';

  /// A duração atual da contagem regressiva (usada pelo timer).
  late Duration _duration;

  /// O timer principal que decrementa a duração a cada segundo.
  Timer? _timer;

  /// O timer secundário que controla os efeitos de piscar (blink).
  Timer? _blinkTimer;

  /// Estado booleano para controlar se o texto está no ciclo "piscar".
  bool _isBlinking = false;

  /// Estado booleano para controlar se o cronômetro está rodando.
  bool _isRunning = false;

  /// Método do ciclo de vida chamado quando o widget é inicializado.
  @override
  void initState() {
    super.initState();
    // Define a duração atual com base no valor inicial configurado.
    _duration = _initialDuration;
  }

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
      // Se 'reset' for true, usa a duração inicial configurável.
      if (reset) _duration = _initialDuration;
    });
  }

  /// Pausa o cronômetro no tempo atual.
  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  // --- Lógica de Alertas Visuais (MODIFICADA) ---

  /// Verifica o tempo atual e dispara os alertas visuais correspondentes.
  void _checkTimeForAlerts() {
    final seconds = _duration.inSeconds;

    // Alerta 1: Faltam 10 segundos ou menos (conforme solicitado)
    // 'seconds > 0' evita que isso rode no 0 exato, onde o timer para.
    if (seconds <= 10 && seconds > 0) {
      if (_blinkTimer == null || !_blinkTimer!.isActive) {
        // Inicia o piscar contínuo (vermelho/transparente)
        _startContinuousBlink();
      }
    }
    // Alerta 2: A cada 5 minutos (300s) antes do fim (conforme solicitado)
    // 'seconds > 0' evita acionar isso no 00:00:00
    else if (seconds % 300 == 0 && seconds > 0) {
      // Dispara o alerta de 5 segundos (vermelho/verde)
      _trigger5MinuteAlertBlink();
    }
  }

  /// Inicia um efeito de piscar contínuo, usado nos últimos 10 segundos.
  void _startContinuousBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  /// Dispara um efeito de piscar temporário (VERMELHO/VERDE) por 5 segundos.
  /// Usado para os marcos de 5 minutos.
  void _trigger5MinuteAlertBlink() {
    int blinkCount = 0;
    // 10 ciclos de 500ms = 5 segundos (5x vermelho, 5x verde)
    const int maxBlinks = 10;

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
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
    // Alterado de 5 minutos (300s) para 10 segundos
    final bool isUnder10Sec =
        _duration.inSeconds <= 10 && _duration.inSeconds > 0;

    final defaultGreen = isDarkMode
        ? const Color(0xFF00FF00)
        : const Color.fromARGB(255, 3, 85, 3);

    if (isUnder10Sec) {
      // Nos últimos 10 segundos, alterna entre vermelho e transparente.
      return _isBlinking ? Colors.red : Colors.transparent;
    } else {
      // Nos alertas de 5 min (ou qualquer outro blink), alterna entre vermelho e a cor verde padrão.
      return _isBlinking ? Colors.red : defaultGreen;
    }
  }

  // --- NOVA FUNÇÃO: Diálogo de Configurações ---

  /// Exibe um diálogo modal para configurar o timer e a modalidade.
  void _showSettingsDialog() {
    // Controladores para os campos de texto H, M, S
    final hoursController = TextEditingController(
      text: _initialDuration.inHours.toString(),
    );
    final minutesController = TextEditingController(
      text: _initialDuration.inMinutes.remainder(60).toString(),
    );
    final secondsController = TextEditingController(
      text: _initialDuration.inSeconds.remainder(60).toString(),
    );

    // Lista de modalidades e variável temporária para o dropdown
    const modalities = ['Maratona Robocode', 'Sumo', 'Labirinto'];
    String selectedModality = _modalityName;

    showDialog(
      context: context,
      // Impede fechar o diálogo clicando fora se o timer estiver rodando
      barrierDismissible: !_isRunning,
      builder: (context) {
        // StatefulBuilder é usado para atualizar o estado *dentro* do diálogo (o dropdown)
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurações do Timer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Seletor de Modalidade ---
                    Text(
                      'Modalidade',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedModality,
                      isExpanded: true,
                      items: modalities.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            // Atualiza o estado do diálogo
                            selectedModality = newValue;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Seletor de Tempo ---
                    Text(
                      'Duração',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Horas
                        Expanded(
                          child: TextField(
                            controller: hoursController,
                            decoration: const InputDecoration(
                              labelText: 'HH',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Minutos
                        Expanded(
                          child: TextField(
                            controller: minutesController,
                            decoration: const InputDecoration(
                              labelText: 'MM',
                              border: OutlineInputBorder(),
                              counterText: "", // Remove o contador
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Segundos
                        Expanded(
                          child: TextField(
                            controller: secondsController,
                            decoration: const InputDecoration(
                              labelText: 'SS',
                              border: OutlineInputBorder(),
                              counterText: "", // Remove o contador
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                // Botão Cancelar
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                // Botão Salvar
                ElevatedButton(
                  onPressed: () {
                    // --- Lógica de Salvamento ---
                    final h = int.tryParse(hoursController.text) ?? 0;
                    final m = int.tryParse(minutesController.text) ?? 0;
                    final s = int.tryParse(secondsController.text) ?? 0;

                    if (_isRunning) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Timer resetado para aplicar novas configurações.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }

                    // Atualiza o estado principal (fora do diálogo)
                    setState(() {
                      _modalityName = selectedModality;
                      _initialDuration = Duration(
                        hours: h,
                        minutes: m,
                        seconds: s,
                      );
                      // Reseta o timer atual para a nova duração
                      _stopTimer(reset: true);
                    });

                    Navigator.of(context).pop(); // Fecha o diálogo
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Constrói a interface gráfica do widget.
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = widget.currentTheme == ThemeMode.dark;
    // Pega a cor de ícone padrão do tema atual
    final iconColor = Theme.of(context).iconTheme.color;

    return Scaffold(
      // Stack é usado para permitir a sobreposição dos botões de tema/config.
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
                    // Placeholder (substitua pelo seu Image.asset)
                    Image.asset('assets/logorobochallenge.png', height: 250),
                    Expanded(
                      child: Text(
                        _modalityName, // <-- Alterado para usar a variável de estado
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    // Placeholder (substitua pelo seu Image.asset)
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

          // --- Botões Flutuantes (Tema e Configurações) ---
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // Coluna para empilhar os botões verticalmente
              child: Column(
                mainAxisSize: MainAxisSize.min, // Para encolher a coluna
                children: [
                  // Botão de Tema
                  IconButton(
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    iconSize: 30,
                    tooltip: 'Mudar Tema',
                    onPressed: widget.onThemeChanged,
                    color: iconColor, // Adiciona a cor do tema
                  ),
                  const SizedBox(height: 16), // Espaçamento
                  // NOVO: Botão de Configurações
                  IconButton(
                    icon: const Icon(Icons.settings),
                    iconSize: 30,
                    tooltip: 'Configurações',
                    onPressed: _showSettingsDialog, // Chama o novo diálogo
                    color: iconColor, // Adiciona a cor do tema
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
