plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mustafabch.hsoub"
    
    // يفضل استخدام رقم نسخة مستقرة (مثل 34 أو 35) إلا إذا كنت تستخدم نسخة المطورين
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    compileOptions {
        // ✅ تفعيل Desugaring لحل مشكلة الإشعارات
        isCoreLibraryDesugaringEnabled = true
        
        // يمكنك استخدام VERSION_1_8 أو VERSION_17 (كلاهما يعمل مع Desugaring)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.mustafabch.hsoub"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ تفعيل MultiDex ضروري مع المكتبات الكبيرة
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            
            // إعدادات تصغير حجم التطبيق (اختيارية لكن موصى بها)
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    // 👇 تأكد أن الرقم هنا هو 2.1.4 وليس 2.0.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.0")
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}


flutter {
    source = "../.."
}