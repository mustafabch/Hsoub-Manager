import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart'; 

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
  final List<InAppWebViewController?> _controllers = [null, null, null, null];

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
    const Color(0xFFC4740C),
    const Color(0xFF2895DB),
    const Color(0xFF803588),
    const Color(0xFF7566f1),
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
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
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

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final controller = _controllers[_currentIndex];
        if (controller != null && await controller.canGoBack()) {
          controller.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: _isDarkMode ? _darkBg : _lightBg,
        
        endDrawer: Drawer(
          backgroundColor: _isDarkMode ? _darkSurface : _lightSurface,
          child: SafeArea(
            bottom: true, 
            top: false,
            child: Directionality(
              textDirection: TextDirection.rtl, 
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: _isDarkMode ? _darkBg : Colors.grey.shade200,
                      border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))
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
                    leading: Icon(Icons.dashboard_customize_outlined, color: _isDarkMode ? Colors.white70 : Colors.black54),
                    title: Text(
                      "عن التطبيق",
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
                    },
                  ),

                  ListTile(
                    leading: Icon(Icons.code, color: _isDarkMode ? Colors.white70 : Colors.black54),
                    title: Text(
                      "عن المطور", 
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                    },
                  ),
                  const SizedBox(height: 60), 
                ],
              ),
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
        
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: List.generate(_urls.length, (index) {
              return HsoubWebView(
                url: _urls[index], 
                isDarkMode: _isDarkMode,
                customCss: _loadedCss,
                onControllerCreated: (controller) {
                  _controllers[index] = controller;
                },
              );
            }),
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
  final Function(InAppWebViewController) onControllerCreated;

  const HsoubWebView({
    super.key, 
    required this.url, 
    required this.isDarkMode,
    this.customCss,
    required this.onControllerCreated,
  });

  @override
  State<HsoubWebView> createState() => _HsoubWebViewState();
}

class _HsoubWebViewState extends State<HsoubWebView> with AutomaticKeepAliveClientMixin {
  InAppWebViewController? webViewController;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; 

  // ✅ 1. كود الخطوط (يتم حقنه دائماً لضمان الخط في الوضع النهاري والليلي)
  static const String cssFonts = """
    @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@100;200;300;400;500;600;700&display=swap');
    
    /* تعميم الخط على كامل الموقع مع !important */
    * { 
      font-family: 'IBM+Plex+Sans+Arabic', 'IBM Plex Sans Arabic', sans-serif !important; 
    }

    /* استثناء الأيقونات (FontAwesome وغيرها) حتى لا تختفي */
    /* نعيدها للوراثة inherit لتأخذ الخط الذي حدده الموقع */
    .fa, .fas, .far, .fab, .fal, 
    [class*="icon-"], [class*="hsoub-icon"], .hsoub-icon,
    i, span[class^="icon-"] {
        font-family: inherit !important;
    }
  """;

  // ✅ 2. كود الوضع الليلي (فلاتر فقط)
  static const String cssDarkModeContent = """
    /* قلب الألوان للخلفية */
    html { filter: invert(0.92) hue-rotate(180deg) brightness(1.1); background-color: #1a1a1a !important; }

    /* إعادة الوسائط والخلفيات لطبيعتها */
    img, video, iframe, canvas, svg, .video_bg,
    .avatar, .user-avatar, .product-img, .block-images-unit-background, .show-thumb, .thumb,
    [style*="background-image"], [style*="background: url"], [style*="background:url"] {
        filter: invert(1) hue-rotate(180deg) !important;
    }

    /* استثناء الحاويات الملونة (هيدر مستقل، أيقونات خدمات خمسات) */
    .hero, .grid-item {
        filter: invert(1) hue-rotate(180deg) !important;
    }
    
    /* حماية محتوى الحاويات المستثناة من القلب المزدوج */
    .hero video, .hero-full-height video, 
    .hero .video_bg, 
    .grid-item img, .grid-item svg {
        filter: none !important;
    }

    /* 🔥 إصلاح خاص لفيديو خمسات (.khamsat-hero) */
    /* نجبر فيديو خمسات على عدم استخدام الفلتر ليبقى طبيعياً داخل الهيدر */
    .khamsat-hero video, .khamsat-hero .video_bg {
         filter: none !important;
    }
      .dashboard {
         background-color: #ffffff !important; /* this fix the white bg in mostaql dashboard */
    }

    /* إصلاح نصوص هيدر خمسات (لأن الهيدر أصبح ساطعاً، فالنصوص انقلبت للأسود، نعيدها للأبيض) */
    .khamsat-hero .hero-title, .khamsat-hero p, .khamsat-hero h1, .khamsat-hero h2, .khamsat-hero .hero-form {
         filter: invert(1) hue-rotate(180deg);
         text-shadow: 0 0 5px rgba(0,0,0,0.5);
    }
  """;

  // دالة التبديل (تضيف/تحذف ملف ستايل الوضع الليلي فقط)
  void _toggleDarkMode(bool enable) {
    if (webViewController == null) return;

    if (enable) {
      String jsCode = """
        if (!document.getElementById('hsoub-dark-mode-style')) {
          var style = document.createElement('style');
          style.id = 'hsoub-dark-mode-style';
          style.innerHTML = `$cssDarkModeContent`;
          document.head.appendChild(style);
        }
      """;
      webViewController!.evaluateJavascript(source: jsCode);
    } else {
      String jsCode = """
        var style = document.getElementById('hsoub-dark-mode-style');
        if (style) { style.remove(); }
      """;
      webViewController!.evaluateJavascript(source: jsCode);
    }
  }

  @override
  void didUpdateWidget(HsoubWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (webViewController != null) {
      if (widget.isDarkMode != oldWidget.isDarkMode) {
        _toggleDarkMode(widget.isDarkMode);
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
            widget.onControllerCreated(controller);
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
            });
          },
          onLoadStop: (controller, url) async {
            // ✅ 1. حقن الخطوط (دائماً وفي كل الأوضاع)
            // نستخدم injectCSSCode للخطوط لأننا نريدها ثابتة
            await controller.injectCSSCode(source: cssFonts);
            
            // إضافة ملف custom.css الإضافي إذا وجد
            if (widget.customCss != null) {
              await controller.injectCSSCode(source: widget.customCss!);
            }
            
            // ✅ 2. تفعيل الوضع الليلي إذا كان مختاراً
            if (widget.isDarkMode) {
              _toggleDarkMode(true);
            }

            // ... (حفظ الكوكيز) ...
            if (url.toString().contains('hsoub.com') || 
                url.toString().contains('khamsat.com') ||
                url.toString().contains('mostaql.com') ||
                url.toString().contains('baaeed.com') ||
                url.toString().contains('picalica.com')) {
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

// ... (AboutAppScreen و AboutScreen كما هي دون تغيير)
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark ? Colors.grey : Colors.grey[700];

    final List<Map<String, dynamic>> platforms = [
      {'name': 'خمسات', 'color': const Color(0xFFC4740C), 'logo': 'khamsat.svg', 'url': 'https://khamsat.com'},
      {'name': 'مستقل', 'color': const Color(0xFF2895DB), 'logo': 'mostaql.svg', 'url': 'https://mostaql.com'},
      {'name': 'بيكاليكا', 'color': const Color(0xFF803588), 'logo': 'picalica.svg', 'url': 'https://picalica.com'},
      {'name': 'بعيد', 'color': const Color(0xFF7566f1), 'logo': 'baaeed.svg', 'url': 'https://baaeed.com'},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181a1f) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF181a1f) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "عن التطبيق", 
          style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic')
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            SvgPicture.network(
              "https://static.hsoubcdn.com/footer/assets/images/hsoub-logo.svg",
              width: 120,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : Colors.black87,
                BlendMode.srcIn
              ),
            ),
            
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21252b) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)
              ),
              child: Column(
                children: [
                  Text(
                    "Hsoub Platforms Manager",
                    style: TextStyle(
                      color: textColor, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic'
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "تطبيق غير رسمي يجمع كافة منصات شركة حسوب في مكان واحد لتسهيل الوصول إليها وإدارتها، مع دعم للوضع الليلي ونظام التنبيهات الذكي.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 14,
                      height: 1.6,
                      fontFamily: 'IBM Plex Sans Arabic'
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "المنصات المدعومة",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic'
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: platforms.map((platform) {
                return InkWell(
                  onTap: () => _launchUrl(platform['url']),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF21252b) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          "assets/logos/${platform['logo']}",
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            platform['color'],
                            BlendMode.srcIn
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          platform['name'],
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic'
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 30),
            Text(
              "الإصدار 1.0.0",
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchSocial(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark ? Colors.grey : Colors.grey[700];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181a1f) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF181a1f) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "عن المطور", 
          style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic')
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF21252b) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: SvgPicture.asset(
                  "assets/logos/graphixy.svg",
                  width: 100,
                  height: 100,
                ),
              ),
              
              const SizedBox(height: 25),

              Text(
                "Graphixy Agency",
                style: TextStyle(
                  color: textColor, 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic'
                ),
              ),
              
              const SizedBox(height: 10),

              Text(
                "نحول الأفكار إلى واقع رقمي مذهل.\nوكالة متخصصة في التصميم الجرافيكي، تطوير التطبيقات، وحلول الويب المتكاملة.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14,
                  height: 1.5, 
                  fontFamily: 'IBM Plex Sans Arabic'
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF21252b) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)
                ),
                child: Column(
                  children: [
                    Text(
                      "تواصل معنا",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic'
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialBtn(
                          icon: Icons.language, 
                          color: Colors.blue, 
                          onTap: () => _launchSocial("https://graphixy.agency")
                        ),
                        _buildSocialBtn(
                          icon: Icons.facebook, 
                          color: const Color(0xFF1877F2), 
                          onTap: () => _launchSocial("https://facebook.com/graphixyagency")
                        ),
                        _buildSocialBtn(
                          icon: Icons.camera_alt,
                          color: const Color(0xFFE4405F), 
                          onTap: () => _launchSocial("https://instagram.com/graphixy.agency")
                        ),
                        _buildSocialBtn(
                          icon: Icons.alternate_email, 
                          color: Colors.orange, 
                          onTap: () => _launchSocial("mailto:hello@graphixy.ru")
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "جميع الحقوق محفوظة © 2026\nGraphixy Agency",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryColor, 
                  fontSize: 12,
                  fontFamily: 'IBM Plex Sans Arabic'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}