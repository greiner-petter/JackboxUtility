import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:jackbox_patcher/app_configuration.dart';
import 'package:jackbox_patcher/main.dart';
import 'package:jackbox_patcher/services/arguments_handler/arguments_handler.dart';
import 'package:jackbox_patcher/services/user/initial_load.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'services/logger/logger.dart';

Future<void> initPlatformChannels() async {
  MethodChannel('macos_channel').setMethodCallHandler((MethodCall call) async {
    if (call.method == 'request_close') {
      await windowManager.close();
      return 'ok';
    }
    throw PlatformException(code: 'UNIMPLEMENTED', details: call.method);
  });
}

void initRetrievingErrors() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    JULogger().e("[ON ERROR] $details", error: details.exception, stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    bool ifIsOverflowError = error.toString().contains("A RenderFlex overflowed by");

    if (!ifIsOverflowError) JULogger().e("[ON ERROR] $error", error: error, stackTrace: stack);
    return true;
  };
}

void main(List<String> arguments) async {
  FlavorConfig(
      name: "RELEASE",
      color: Colors.orange,
      variables: {"masterServerUrl": MAIN_SERVER_URL["RELEASE_SERVER_URL"], "loggerLevel": Level.error});

  await InitialLoad.preInit();

  if (await ArgumentsHandler().handle(arguments)) {
    exit(0);
  }
  initRetrievingErrors();
  await initPlatformChannels();
  await SentryFlutter.init(
    (options) {
      options.environment = "production";
      options.dsn = 'https://bc7660c906ba4f24ad2e37530bfa4c39@o518501.ingest.sentry.io/4504978536988672';
    },
    // Init your App.
    appRunner: () => runApp(MyApp()),
  );
}
