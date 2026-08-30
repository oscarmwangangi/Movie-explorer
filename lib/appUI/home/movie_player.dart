import 'dart:async';
import 'dart:io' show Platform, Directory;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_explorer/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:window_manager/window_manager.dart';
import 'package:movie_explorer/main.dart';
import 'package:movie_explorer/appUI/services/watch_history_service.dart';

class MoviePlayerScreen extends StatefulWidget {
  final int tmdbId;
  final String title;
  final bool isTv;
  final int season;
  final int episode;
  final String? posterPath;
  final String? backdropPath;
  final num? voteAverage;

  const MoviePlayerScreen({
    required this.tmdbId,
    required this.title,
    this.isTv = false,
    this.season = 1,
    this.episode = 1,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    super.key,
  });

  @override
  State<MoviePlayerScreen> createState() => _MoviePlayerScreenState();
}

class _MoviePlayerScreenState extends State<MoviePlayerScreen> with WindowListener {
  // Mobile/macOS path (webview_flutter has native platform support there).
  WebViewController? _controller;

  // Windows path — flutter_inappwebview handles the WebView2 environment
  // more robustly than the older webview_windows package.
  InAppWebViewController? _winController;
  WebViewEnvironment? _webViewEnvironment;
  bool _winInitFailed = false;
  bool _hasLoadedOnce = false;
  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isMinimized = false;

  bool isLoading = true;
  double loadingProgress = 0;
  late final String _playerUrl;

  bool get _isWindows => !kIsWeb && Platform.isWindows;
  bool get _isLinux => !kIsWeb && Platform.isLinux;

  @override
  void initState() {
    super.initState();
    if (_isWindows) {
      windowManager.addListener(this);
    }

    // Record this open for the Home screen's Continue Watching rail.
    // See WatchHistoryService for why this tracks "recently opened"
    // rather than a verified playback percentage.
    WatchHistoryService.recordWatch(
      {
        'id': widget.tmdbId,
        'title': widget.title,
        'name': widget.title,
        'poster_path': widget.posterPath,
        'backdrop_path': widget.backdropPath,
        'vote_average': widget.voteAverage,
      },
      isTv: widget.isTv,
      season: widget.isTv ? widget.season : null,
      episode: widget.isTv ? widget.episode : null,
    );

    // Construct the player URL using environment variables
    final tvBase = dotenv.env['PLAYER_TV_URL'] ?? "https://vidsrc.to/embed/tv";
    final movieBase = dotenv.env['PLAYER_MOVIE_URL'] ?? "https://vidsrc.to/embed/movie";

    _playerUrl = widget.isTv
        ? "$tvBase/${widget.tmdbId}/${widget.season}/${widget.episode}"
        : "$movieBase/${widget.tmdbId}";

    if (_isWindows) {
      _initWindowsWebview();
      return;
    }

    // Linux has neither webview_flutter nor a maintained WebView2-style
    // package — this is a genuine gap, not something faked with an
    // overlay. Fall back to opening the stream in the system browser.
    if (_isLinux) {
      isLoading = false;
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent("Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1",)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final String url = request.url.toLowerCase();
            // List of allowed domains (player and its essential scripts)
            if (url.contains("vidsrc.to") ||
                url.contains("vidsrc.me") ||
                url.contains("vsembed.ru") ||
                url.contains("2embed.cc") ||
                url.contains("google.com") || // Sometimes needed for captchas/analytics
                url.contains("gstatic.com")) {
              return NavigationDecision.navigate;
            }

            // Block everything else (likely popups/ads)
            debugPrint("Blocked navigation to: $url");
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(_playerUrl));
  }

  Future<void> _initWindowsWebview() async {
    if (!Platform.isWindows) return;

    // Use the pre-initialized global environment to avoid lock/freeze issues
    if (globalWebViewEnvironment != null) {
      _webViewEnvironment = globalWebViewEnvironment;
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Fallback if global init failed
      try {
        final String? localAppData = Platform.environment['LOCALAPPDATA'];
        final String userDataFolder = localAppData != null
            ? "$localAppData\\MovieExplorer\\webview_data"
            : "${Directory.systemTemp.path}\\MovieExplorer\\webview_data";

        await Directory(userDataFolder).create(recursive: true);

        _webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(userDataFolder: userDataFolder),
        );

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error initializing WebView2 environment: $e");
        if (mounted) {
          setState(() {
            _winInitFailed = true;
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_playerUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    if (_isWindows) {
      windowManager.removeListener(this);
    }
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  void onWindowMinimize() {
    if (mounted && _isWindows) {
      setState(() {
        _isMinimized = true;
      });
    }
  }

  @override
  void onWindowRestore() {
    if (mounted && _isWindows) {
      setState(() {
        _isMinimized = false;
        isLoading = true;
        _hasLoadedOnce = false;
      });
    }
  }

  void _toggleRotation() {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _toggleWindowsFullScreen() async {
    bool nowFull = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!nowFull);
    // Adding a small delay helps WebView2 recalibrate its surface
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _isFullScreen = !nowFull;
        if (_isFullScreen) _startHideTimer();
      });
    }
  }

  Future<void> _exitWindowsFullScreen() async {
    if (_isWindows && _isFullScreen) {
      await windowManager.setFullScreen(false);
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _isFullScreen = false;
          _showControls = true;
        });
      }
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isFullScreen) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onMouseMoved() {
    if (!_showControls) {
      setState(() => _showControls = true);
    }
    if (_isFullScreen) {
      _startHideTimer();
    }
  }

  Widget _buildBrowserFallback(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.open_in_new, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Watch in browser"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget body;
    if (_isWindows) {
      if (_winInitFailed) {
        body = _buildBrowserFallback(
          "Couldn't start the in-app player (WebView2 Runtime may be missing).",
        );
      } else if (_webViewEnvironment == null) {
        body = const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      } else {
        body = MouseRegion(
          onHover: (_) => _onMouseMoved(),
          child: Stack(
            children: [
              if (!_isMinimized)
                InAppWebView(
                  webViewEnvironment: _webViewEnvironment,
                  initialUrlRequest: URLRequest(url: WebUri(_playerUrl)),
                initialSettings: InAppWebViewSettings(
                  // Use an Android Phone User Agent. This provides the mobile player
                  // (which has resolution settings) while keeping ads under control.
                  userAgent:
                      "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  transparentBackground: false, // Changed to false to prevent freeze on some GPUs during resize
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: false,
                  supportMultipleWindows: false,
                  isInspectable: kDebugMode,
                ),
                onWebViewCreated: (controller) {
                  _winController = controller;
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    loadingProgress = progress / 100;
                    if (progress > 80) {
                      isLoading = false;
                      _hasLoadedOnce = true;
                    }
                  });
                },
                onLoadStart: (controller, url) {
                  if (!_hasLoadedOnce) {
                    setState(() => isLoading = true);
                  }
                },
                onLoadStop: (controller, url) async {
                  setState(() {
                    isLoading = false;
                    _hasLoadedOnce = true;
                  });
                  // Force a black background and try to auto-click play if possible
                  await controller.evaluateJavascript(source: """
                  document.body.style.backgroundColor = 'black';
                  // Attempt to remove any overlaying div that might be a transparent ad-gate
                  var divs = document.getElementsByTagName('div');
                  for(var i=0; i<divs.length; i++) {
                    if(divs[i].style.zIndex > 1000) divs[i].remove();
                  }
                """);
                },
                onLoadError: (controller, url, code, message) {
                  debugPrint("WebView Load Error: $message (code: $code) at $url");
                },
                onLoadHttpError: (controller, url, statusCode, description) {
                  debugPrint("WebView HTTP Error: $description (status: $statusCode) at $url");
                },
                onCreateWindow: (controller, createWindowAction) async {
                  return false;
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;
                  if (uri == null) return NavigationActionPolicy.CANCEL;

                  final url = uri.toString().toLowerCase();

                  // Strictly allow only the player domains and essential scripts.
                  final isPlayerDomain = url.contains("vidsrc") ||
                      url.contains("vsembed") ||
                      url.contains("2embed") ||
                      url.contains("vidplay") ||
                      url.contains("moviesapi") ||
                      url.contains("megacloud") ||
                      url.contains("vizcloud") ||
                      url.contains("rabbit") ||
                      url.contains("bunny");

                  final isInfrastructure = url.contains("google.com") ||
                      url.contains("gstatic.com") ||
                      url.contains("cloudflare") ||
                      url.contains("hcaptcha") ||
                      url.contains("recaptcha");

                  if (navigationAction.isForMainFrame) {
                    if (isPlayerDomain || isInfrastructure || url == _playerUrl.toLowerCase()) {
                      return NavigationActionPolicy.ALLOW;
                    }
                    debugPrint("Blocking main frame redirect to: $url");
                    // If an ad tries to hijack the main view, we stay on the current page.
                    return NavigationActionPolicy.CANCEL;
                  }

                  // For subframes (ads, etc.), we block them unless they are part of the player infrastructure.
                  if (!isPlayerDomain && !isInfrastructure) {
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
              ),
              if (isLoading)
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: loadingProgress > 0 ? loadingProgress : null,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 16),
                        const Text("Loading stream...", style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              // Floating exit button for Full Screen
              if (_isWindows && _isFullScreen && _showControls)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
                      tooltip: "Exit Full Screen (Esc)",
                      onPressed: _exitWindowsFullScreen,
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    } else if (_isLinux) {
      body = _buildBrowserFallback("Playback opens in your browser on Linux.");
    } else {
      body = Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 16),
                    Text("Loading stream...", style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // The landscape/portrait immersive toggle only makes sense on phones
    // that physically rotate — a desktop window is almost always wider
    // than tall, so this used to always evaluate to "landscape" on
    // Windows/Linux and hide the AppBar (and its back button) entirely.
    final bool hideAppBar = _isFullScreen || (!_isWindows && !_isLinux && isLandscape);

    final playerScaffold = Scaffold(
      backgroundColor: Colors.black,
      appBar: hideAppBar
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () async {
                  if (_isFullScreen) {
                    await windowManager.setFullScreen(false);
                  }
                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                  if (mounted) Navigator.pop(context);
                },
              ),
              actions: [
                if (_isWindows) ...[
                  IconButton(
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: _toggleWindowsFullScreen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      _winController?.reload();
                    },
                  ),
                ],
                if (!_isWindows && !_isLinux)
                  IconButton(
                    icon: const Icon(Icons.screen_rotation, color: Colors.white),
                    onPressed: _toggleRotation,
                  ),
              ],
            ),
      body: body,
    );

    if (_isWindows) {
      return KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
            _exitWindowsFullScreen();
          }
        },
        child: playerScaffold,
      );
    }

    return playerScaffold;
  }
}
