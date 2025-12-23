import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:logger/logger.dart';

const String fetchBackground = "fetchBackground";

// إعداد اللوجر (Logger) بتنسيق نظيف
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
        logger.d("بدأت عملية الفحص في الخلفية... 🕵️‍♂️"); 
        await NotificationService.checkNotifications();
        break;
    }
    return Future.value(true);
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);

    // تفعيل Workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      // isInDebugMode: true, // فعل هذا السطر فقط إذا أردت رؤية إشعارات تجريبية كثيرة
    );
  }

  static Future<void> scheduleBackgroundFetch() async {
    await Workmanager().registerPeriodicTask(
      "1", 
      fetchBackground,
      frequency: const Duration(minutes: 15), 
      constraints: Constraints(
        networkType: NetworkType.connected, 
      ),
    );
  }

  static Future<void> checkNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cookies = prefs.getString('hsoub_cookies');

    if (cookies == null) {
      logger.i("لا توجد كوكيز مسجلة. تخطي الفحص."); 
      return; 
    }

    try {
      final response = await http.get(
        Uri.parse('https://khamsat.com'),
        headers: {
          'Cookie': cookies,
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) HsoubApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        // البحث عن أيقونة الإشعارات التي تحتوي على رقم
        var notificationElements = document.querySelectorAll('.header-notifications .badge, .notifications-count, .message-count');

        for (var element in notificationElements) {
          String text = element.text.trim();
          int? count = int.tryParse(text);
          
          if (count != null && count > 0) {
            logger.i("تم العثور على $count إشعار!");
            await _showNotification(count);
            break; 
          }
        }
      } else {
        logger.w("فشل تحميل الصفحة: ${response.statusCode}"); 
      }
    } catch (e) {
      logger.e("خطأ في جلب الإشعارات", error: e); 
    }
  }

  static Future<void> _showNotification(int count) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hsoub_channel_id',
      'تنبيهات حسوب',
      channelDescription: 'إشعارات عند وصول رسائل أو تحديثات جديدة',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'لديك تنبيهات جديدة',
      'يوجد $count إشعار جديد في حسابك',
      details,
    );
  }
}