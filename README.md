# Cronômetro de Evento - Robochallenge

Um aplicativo de cronômetro de contagem regressiva em tela cheia, desenvolvido com Flutter para a plataforma Windows. Ideal para ser exibido em telas grandes durante eventos, maratonas de programação e competições como a Robochallenge.

![Screenshot do Aplicativo](link_para_sua_imagem.png)
*(Substitua a imagem acima por um screenshot real do seu aplicativo em execução)*

---

## ✨ Funcionalidades

- **Contagem Regressiva:** Inicia uma contagem a partir de um tempo pré-definido (atualmente 2 horas).
- **Controles Simples:** Botões de **Iniciar**, **Pausar** e **Resetar**.
- **Layout Responsivo:** O cronômetro se ajusta à largura e altura da tela.
- **Tema Dual:** Suporte para temas **claro** e **escuro**, com um botão para alternar facilmente.
- **Identidade Visual:** Espaços para logos do evento e de parceiros.
- **Fontes Personalizadas:** Usa fontes customizadas para um visual temático.
- **Alertas Visuais Inteligentes:**
  - O cronômetro pisca em **vermelho** momentaneamente ao atingir as marcas de 1h30, 1h00 e 0h30.
  - O cronômetro fica **permanentemente vermelho e piscando** durante os últimos 5 minutos.

---

## 🛠️ Pré-requisitos

- **Flutter SDK:** Certifique-se de ter o Flutter instalado e configurado em sua máquina. [Guia de Instalação](https://flutter.dev/docs/get-started/install).
- **Suporte para Windows:** Verifique se o seu ambiente Flutter está habilitado para desenvolvimento Windows. Execute `flutter doctor` para confirmar.

---

## 🚀 Instalação e Configuração

1.  **Clone o Repositório:**
    ```bash
    git clone [https://github.com/seu-usuario/seu-repositorio.git](https://github.com/seu-usuario/seu-repositorio.git)
    cd seu-repositorio
    ```

2.  **Adicione os Assets:**
    - Crie uma pasta `assets` na raiz do projeto.
    - Adicione suas imagens de logo (`logorobochallenge.png`, `logoiceipucminas.png`).

3.  **Adicione a Fonte:**
    - Crie uma pasta `fonts` na raiz do projeto.
    - Adicione o arquivo da fonte desejada (ex: `RobotoMono-Bold.ttf`).
    - *Certifique-se de que os assets e fontes estão declarados corretamente no arquivo `pubspec.yaml`.*

4.  **Instale as Dependências:**
    ```bash
    flutter pub get
    ```

---

## 🏃‍♂️ Executando a Aplicação

Para executar o aplicativo no modo de depuração, utilize o seguinte comando no terminal:

```bash
flutter run -d windows
```

Para gerar uma versão de produção (executável), use:

```bash
flutter build windows
```
O executável será gerado em `build/windows/runner/Release/`.

---

## 📂 Estrutura do Projeto

```
/
├── assets/               # Contém as imagens das logos.
├── fonts/                # Contém os arquivos de fonte personalizados.
├── lib/
│   └── main.dart         # Código-fonte principal da aplicação.
├── windows/              # Arquivos de configuração específicos para Windows.
└── pubspec.yaml          # Define as dependências e assets do projeto.
```

---

## 🎨 Personalização

-   **Duração do Timer:** Para alterar o tempo inicial, modifique a constante `_initialDuration` na classe `_CountdownScreenState`.
    ```dart
    static const _initialDuration = Duration(hours: 3, minutes: 30); // Exemplo
    ```
-   **Fontes e Cores:** As fontes e cores padrão são definidas no `TextStyle` do widget `Text` do cronômetro e na função `_getTimerColor`.
-   **Logos:** Para alterar os logos, simplesmente substitua os arquivos de imagem na pasta `/assets`.