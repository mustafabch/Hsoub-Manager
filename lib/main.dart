import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'services/notification_service.dart';

final uiLogger = Logger(printer: PrettyPrinter(methodCount: 0));

const String customMoonIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
  <path d="M9.822 2.238a9 9 0 0 0 11.94 11.94C20.768 18.654 16.775 22 12 22 6.477 22 2 17.523 2 12c0-4.775 3.346-8.768 7.822-9.762m8.342.053L19 2.5v1l-.836.209a2 2 0 0 0-1.455 1.455L16.5 6h-1l-.209-.836a2 2 0 0 0-1.455-1.455L13 3.5v-1l.836-.209A2 2 0 0 0 15.29.836L15.5 0h1l.209.836a2 2 0 0 0 1.455 1.455m5 5L24 7.5v1l-.836.209a2 2 0 0 0-1.455 1.455L21.5 11h-1l-.209-.836a2 2 0 0 0-1.455-1.455L18 8.5v-1l.836-.209a2 2 0 0 0 1.455-1.455L20.5 5h1l.209.836a2 2 0 0 0 1.455 1.455"/>
</svg>
''';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService.scheduleBackgroundFetch();
  runApp(const HsoubApp());
}

class HsoubApp extends StatelessWidget {
  const HsoubApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color grapheneBg = Color(0xFF181a1f);
    const Color grapheneSurface = Color(0xFF21252b);
    const String appFont = 'IBM Plex Sans Arabic';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hsoub Platforms',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: grapheneBg,
        primaryColor: grapheneSurface,
        fontFamily: appFont,
        appBarTheme: const AppBarTheme(
          backgroundColor: grapheneBg,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: grapheneSurface,
          surfaceTintColor: grapheneSurface,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: appFont),
          titleLarge: TextStyle(fontFamily: appFont, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isDarkMode = true;
  String? _loadedCss;

  final Color _darkBg = const Color(0xFF181a1f);
  final Color _darkSurface = const Color(0xFF21252b);
  final Color _lightBg = const Color(0xFFF5F5F5);
  final Color _lightSurface = Colors.white;

  final List<String> _urls = [
    "https://khamsat.com",
    "https://mostaql.com",
    "https://picalica.com",
    "https://baaeed.com",
  ];

  final List<Color> _brandColors = [
    const Color(0xFFC4740C), // خمسات
    const Color(0xFF2895DB), // مستقل
    const Color(0xFF803588), // بيكاليكا
    const Color(0xFF7566f1), // بعيد
  ];

  final List<String> _titles = [
    "خمسات",
    "مستقل",
    "بيكاليكا",
    "بعيد",
  ];

  final List<String> _logoAssets = [
    "khamsat.svg",
    "mostaql.svg",
    "picalica.svg",
    "baaeed.svg",
  ];

  @override
  void initState() {
    super.initState();
    _loadCssFile();
  }

  Future<void> _loadCssFile() async {
    try {
      String css = await rootBundle.loadString('assets/css/custom.css');
      setState(() {
        _loadedCss = css;
      });
    } catch (e) {
      uiLogger.e("Error loading CSS file", error: e);
    }
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark
    );

    return Scaffold(
      backgroundColor: _isDarkMode ? _darkBg : _lightBg,
      
      endDrawer: Drawer(
        backgroundColor: _isDarkMode ? _darkSurface : _lightSurface,
        child: Directionality(
          textDirection: TextDirection.rtl, 
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: _isDarkMode ? _darkBg : Colors.grey.shade200,
                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.network(
                        "https://static.hsoubcdn.com/footer/assets/images/hsoub-logo.svg",
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          _isDarkMode ? Colors.white : Colors.black87,
                          BlendMode.srcIn
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "منصات حسوب",
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              ...List.generate(_titles.length, (index) => ListTile(
                leading: SvgPicture.asset(
                  "assets/logos/${_logoAssets[index]}",
                  width: 35, 
                  colorFilter: ColorFilter.mode(
                    _currentIndex == index ? _brandColors[index] : (_isDarkMode ? Colors.grey : Colors.grey.shade600),
                    BlendMode.srcIn
                  ),
                ),
                title: Text(
                  _titles[index],
                  style: TextStyle(
                    color: _currentIndex == index 
                        ? _brandColors[index] 
                        : (_isDarkMode ? Colors.white : Colors.black87),
                    fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                selected: _currentIndex == index,
                onTap: () => _onMenuItemSelected(index),
              )),
              const Divider(height: 1, color: Colors.white10),
              const Spacer(),
              ListTile(
                leading: Icon(Icons.info_outline, color: _isDarkMode ? Colors.white70 : Colors.black54),
                title: Text(
                  "عن التطبيق",
                  style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _isDarkMode ? _darkBg : _lightSurface,
        
        actionsIconTheme: IconThemeData(
          color: _isDarkMode ? Colors.white : Colors.black87
        ),

        leading: IconButton(
          onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          icon: _isDarkMode 
              ? const Icon(Icons.wb_sunny_rounded, size: 28)
              : SvgPicture.string(
                  customMoonIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(Colors.grey[800]!, BlendMode.srcIn),
                ),
          color: _isDarkMode ? const Color(0xFFE5C07B) : null,
        ),
      ),
      
      body: IndexedStack(
        index: _currentIndex,
        children: _urls.map((url) => HsoubWebView(
          url: url, 
          isDarkMode: _isDarkMode,
          customCss: _loadedCss,
        )).toList(),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181a1f),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181a1f),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("عن التطبيق", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.network(
                "https://static.hsoubcdn.com/footer/assets/images/hsoub-logo.svg",
                width: 150,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 30),
              const Text(
                "Hsoub Platforms Manager",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "الإصدار 1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF21252b),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10)
                ),
                child: Column(
                  children: [
                    const Text(
                      "تم التطوير بواسطة",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Mustafa Bch",
                      style: TextStyle(color: Color(0xFF1dbf73), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "جميع الحقوق محفوظة © 2024",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HsoubWebView extends StatefulWidget {
  final String url;
  final bool isDarkMode;
  final String? customCss;

  const HsoubWebView({
    super.key, 
    required this.url, 
    required this.isDarkMode,
    this.customCss,
  });

  @override
  State<HsoubWebView> createState() => _HsoubWebViewState();
}

class _HsoubWebViewState extends State<HsoubWebView> with AutomaticKeepAliveClientMixin {
  InAppWebViewController? webViewController;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; 

  final String cssDark = """
    @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@100;200;300;400;500;600;700&display=swap');
    * { font-family: 'IBM+Plex+Sans+Arabic', 'IBM Plex Sans Arabic', sans-serif !important; }
    
    html { filter: invert(0.9) hue-rotate(180deg) brightness(1.1); }
    img, video, iframe, canvas, svg, .avatar, .user-avatar { 
      filter: invert(1) hue-rotate(180deg);
      transform: translateZ(0); 
    }
    #header, .header, .navbar, .site-footer {
      filter: invert(1) hue-rotate(180deg);
      background-color: #1a1a1a !important; 
      color: #fff !important;
    }
    #header a, .header a, .navbar a, .site-footer a, 
    #header i, .header i, .navbar i, .site-footer i {
      color: #fff !important;
      filter: none !important;
    }
    .card, .panel, .box, .white-bg, .bg-white, .content-box, .dropdown-menu {
      background-color: #fff !important;
      color: #000 !important;
    }
    .btn-primary, .btn-success, .btn-danger {
      filter: invert(1) hue-rotate(180deg);
    }
  """;

  final String cssLightFontFix = """
    @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@100;200;300;400;500;600;700&display=swap');
    * { font-family: 'IBM+Plex+Sans+Arabic', 'IBM Plex Sans Arabic', sans-serif !important; }
  """;

  @override
  void didUpdateWidget(HsoubWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (webViewController != null) {
      if (widget.isDarkMode != oldWidget.isDarkMode) {
        if (widget.isDarkMode) {
          webViewController?.injectCSSCode(source: cssDark);
        } else {
          webViewController?.reload(); 
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            supportZoom: false,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
            });
          },
          onLoadStop: (controller, url) async {
            if (widget.customCss != null) {
              await controller.injectCSSCode(source: widget.customCss!);
            }
            if (widget.isDarkMode) {
              await controller.injectCSSCode(source: cssDark);
            } else {
              await controller.injectCSSCode(source: cssLightFontFix);
            }

            if (url.toString().contains('hsoub.com') || url.toString().contains('khamsat.com')) {
              CookieManager cookieManager = CookieManager.instance();
              List<Cookie> cookies = await cookieManager.getCookies(url: url!);
              String cookieString = cookies.map((c) => "${c.name}=${c.value}").join("; ");
              if (cookieString.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('hsoub_cookies', cookieString);
              }
            }

            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
        
        if (_isLoading)
          Container(
            color: widget.isDarkMode ? const Color(0xFF181a1f) : Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    color: widget.isDarkMode ? const Color(0xFF1dbf73) : const Color(0xFFC4740C),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: SvgPicture.network(
                      "https://static.hsoubcdn.com/footer/assets/images/hsoub-logo.svg",
                      width: 120, 
                      colorFilter: ColorFilter.mode(
                         widget.isDarkMode ? Colors.white : Colors.black87,
                         BlendMode.srcIn
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}