pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven { // For Flutter artifacts (primary location)
            url = uri("https://storage.googleapis.com/flutter_infra_release/flutter/maven/")
        }
        maven { // For Flutter artifacts (alternative/download location)
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
        maven { // For the locally built AAR and its plugins
            url = uri("../inputbaby_flutter/build/host/outputs/repo")
            // You can add content filtering here if needed, e.g.:
            // content {
            //   includeGroupByRegex "com\.example\.inputbaby_flutter.*"
            // }
        }
    }
}

rootProject.name = "NativeInputer"
include(":app")

// --- Flutter Module Integration as per documentation ---
// This assumes 'inputbaby_flutter' is a sibling to your 'NativeInputer' project directory
val flutterModuleRoot = settingsDir.parentFile?.resolve("inputbaby_flutter")
    ?: throw GradleException("Could not determine flutterModuleRoot. settingsDir.parentFile is null.")

val flutterIncludeScript = flutterModuleRoot.resolve(".android/include_flutter.groovy")

if (flutterModuleRoot.exists() && flutterIncludeScript.exists()) {
    // The include_flutter.groovy script will handle including the Flutter module (e.g., as ':flutter')
    // and setting its projectDir, typically to flutterModuleRoot.resolve(".android/Flutter")
    // or flutterModuleRoot itself depending on the Flutter version and setup.

    // Apply the Flutter include script using Kotlin DSL
    apply(from = flutterIncludeScript.path)
} else {
    if (!flutterModuleRoot.exists()) {
        throw GradleException("Flutter module directory not found at ${flutterModuleRoot.path}")
    }
    throw GradleException("Flutter module's include_flutter.groovy not found at ${flutterIncludeScript.path}")
}
// --- End of Flutter Module Integration ---