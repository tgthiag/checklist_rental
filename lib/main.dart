import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

final home_url =
    Uri.parse('https://easyanalytics.com.br/appchecklist/index.html');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..addJavaScriptChannel('Toaster',
        onMessageReceived: (JavaScriptMessage msg) {
      var data = jsonDecode(msg.message);
      if (data["cmd"] == "device") {
        // Handle your JavaScript message here
      }
    })
    ..loadRequest(home_url);

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          mediaPlaybackRequiresUserGesture: false, javaScriptEnabled: true),
      ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          allowsAirPlayForMediaPlayback: true));

  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: InAppWebView(
          initialUrlRequest: URLRequest(url: home_url),
          initialOptions: options,
          androidOnPermissionRequest: (InAppWebViewController controller,
              String origin, List<String> resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          onWebViewCreated: (controller) async {
            setState(() {
              webViewController = controller;
            });
          },
        )),
      );
  }
}
