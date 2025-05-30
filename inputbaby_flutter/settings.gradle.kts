pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def sdkPath = properties.getProperty("flutter.sdk")
        assert sdkPath != null, "flutter.sdk not set in local.properties"
        return sdkPath
    }()
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    // Provide default versions for Android and Kotlin plugins.
    // Subprojects can then apply them by ID if they don't specify a version.
    // Using versions that should be compatible with a modern Flutter setup.
    // The document mentions AGP 8.4. If this fails, we can try slightly older AGP like 7.4.2.
    id "com.android.application" version "8.4.0" apply false // For the wrapper :app module
    id "com.android.library" version "8.4.0" apply false     // For the :Flutter library module
    id "org.jetbrains.kotlin.android" version "1.9.23" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "android_generated"

include ':Flutter'
project(':Flutter').projectDir = new File(settingsDir, 'Flutter')

if (new File(settingsDir, 'app').exists()) {
    include ':app'
    project(':app').projectDir = new File(settingsDir, 'app')
}