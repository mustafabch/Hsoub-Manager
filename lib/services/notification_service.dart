import 'dart:ui'; // ✅ ضروري لتعريف الألوان (Color)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:logger/logger.dart';

const String fetchBackground = "fetchBackground";

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);

@pragma('vm:entry-point') 
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        logger.d("🔍 بدأت عملية الفحص الشامل في الخلفية..."); 
        await NotificationService.checkNotifications();
        break;
    }
    return Future.value(true);
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final Map<String, String> _platforms = {
    'خمسات': 'https://khamsat.com',
    'مستقل': 'https://mostaql.com',
    'بيكاليكا': 'https://picalica.com',
    'بعيد': 'https://baaeed.com',
  };

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);

    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> scheduleBackgroundFetch() async {
    await Workmanager().registerPeriodicTask(
      "hsoub_fetch_task_v1", 
      fetchBackground,
      frequency: const Duration(minutes: 15), 
      constraints: Constraints(
        networkType: NetworkType.connected, 
      ),
      // ✅ التصحيح الأول: استخدام ExistingPeriodicWorkPolicy بدلاً من ExistingWorkPolicy
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace, 
    );
  }

  static Future<void> checkNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cookies = prefs.getString('hsoub_cookies');

    if (cookies == null) {
      logger.i("🚫 لا توجد كوكيز مسجلة. يرجى تسجيل الدخول أولاً."); 
      return; 
    }

    for (var entry in _platforms.entries) {
      await _checkSpecificSite(entry.key, entry.value, cookies);
    }
  }

  static Future<void> _checkSpecificSite(String siteName, String url, String cookies) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Cookie': cookies,
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) HsoubApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        
        var notificationElements = document.querySelectorAll('.header-notifications .badge, .notifications-count, .message-count, .messages-counter');

        int totalCount = 0;

        for (var element in notificationElements) {
          String text = element.text.trim();
          int? count = int.tryParse(text);
          if (count != null) {
            totalCount += count;
          }
        }

        if (totalCount > 0) {
          logger.i("✅ $siteName: تم العثور على $totalCount تنبيه!");
          await _showNotification(siteName.hashCode, siteName, totalCount);
        } else {
          logger.d("⚪ $siteName: لا توجد تنبيهات.");
        }

      } else {
        logger.w("⚠️ $siteName: فشل الاتصال (${response.statusCode})"); 
      }
    } catch (e) {
      logger.e("❌ خطأ أثناء فحص $siteName", error: e); 
    }
  }

  static Future<void> _showNotification(int id, String siteName, int count) async {
    // ✅ التصحيح الثاني: Color أصبحت معرفة بفضل import 'dart:ui'
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hsoub_channel_id',
      'تنبيهات حسوب',
      channelDescription: 'إشعارات منصات حسوب',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF1dbf73), 
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id, 
      'تنبيه من $siteName',
      'لديك $count إشعارات/رسائل جديدة في $siteName',
      details,
    );
  }
}