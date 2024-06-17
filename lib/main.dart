import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';
import 'package:share/share.dart';

final homeUrl =
    WebUri('https://easyanalytics.com.br/rental/propostacomercial/index.html');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? _webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
    javaScriptCanOpenWindowsAutomatically: true,
    javaScriptEnabled: true,
    allowFileAccess: true,
    allowUniversalAccessFromFileURLs: true,
    allowContentAccess: true,
    cacheEnabled: true,
    clearSessionCache: true,
    clearCache: true,
    cacheMode: CacheMode.LOAD_NO_CACHE,
  );

  openPdf(arg) {
    print(arg);
  }

  void showPdfPopup(BuildContext context, String base64PdfData, String nomeArquivo) async {
    final DefaultCacheManager cacheManager = DefaultCacheManager();

    try {
      final fetchedFile = await cacheManager.putFile(
        nomeArquivo.toString(),
        base64Decode(base64PdfData),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Proposta comercial:'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            child: PDFView(
              filePath: fetchedFile.path,
              // Use the fetched file path to display PDF
              enableSwipe: true,
              swipeHorizontal: false,
            ),
          ),
          actions: <Widget>[
            ElevatedButton.icon(
              onPressed: () async {
                final pdfBytes = base64Decode(base64PdfData);
                await Printing.layoutPdf(onLayout: (_) => pdfBytes);
              },
              icon: Icon(Icons.print),
              label: Text(''),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.zero), // Remove padding
                textStyle: MaterialStateProperty.all(
                    TextStyle(fontSize: 0)), // Hide text
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final fileName = nomeArquivo + '.pdf';
                final filePathWithExtension =
                path.join(fetchedFile.parent.path, fileName);

                // Check if the file already exists at the new path
                if (await File(filePathWithExtension).exists()) {
                  // Handle this case, such as generating a unique filename
                  print('File already exists at $filePathWithExtension');
                  await Share.shareFiles(
                    [filePathWithExtension],
                    text: 'Compartilhar PDF',
                  );
                  return;
                }

                // Rename the file to include ".pdf" extension
                try {
                  await fetchedFile.rename(filePathWithExtension);
                  print('File renamed to $filePathWithExtension');
                } catch (e) {
                  print('Error renaming file: $e');
                  return;
                }

                // Share the file using Share.shareFiles
                await Share.shareFiles(
                  [filePathWithExtension],
                  text: 'Compartilhar PDF',
                );
              },
              icon: Icon(Icons.share),
              label: Text(''),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.zero), // Remove padding
                textStyle: MaterialStateProperty.all(
                    TextStyle(fontSize: 0)), // Hide text
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
              label: Text(''),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.zero), // Remove padding
                textStyle: MaterialStateProperty.all(
                    TextStyle(fontSize: 0)), // Hide text
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (_webViewController != null &&
              await _webViewController!.canGoBack()) {
            _webViewController!.goBack();
          }
        },
        child: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: homeUrl),
            onWebViewCreated: (controller) {
              print("teste");
              _webViewController = controller;
              // Add a JavaScript message handler
              controller.addJavaScriptHandler(
                  handlerName: 'openPdf',
                  callback: (args) {
                    // print("teste 3");
                    // print(json.decode(args[0])["texto"]);
                    final jsonArgs = json.decode(args[0])["texto"];
                    final nomeArquivo = json.decode(args[0])["nome"];
                    print(nomeArquivo);
                    // print("a chamada foi um sucesso " + jsonArgs[0]);
                    // // Pass the converted JSON to the functions
                    // openPdf(jsonArgs.toString());
                    showPdfPopup(context, jsonArgs,nomeArquivo);
                  });
            },
            // onLoadStart: (controller, url) {
            //   print("WebView started loading: $url");
            // },
            //           onLoadStop: (controller, url) async {
            //             await controller.evaluateJavascript(source: """
            //   const data = { foo: 'foo_value2', bar: 'bar_value2' };
            //   window.flutter_inappwebview.callHandler('openPdf', JSON.stringify(data));
            // """);
            //           },
            // onReceivedError: (controller, request, error) {
            //   print("WebView error: ${error.description}");
            // },
            // onProgressChanged: (controller, progress) {
            //   print("WebView progress: $progress%");
            // },
            onPermissionRequest: (controller, origin) async {
              return PermissionResponse(
                action: PermissionResponseAction.GRANT,
              );
            },
            onDownloadStartRequest: (controller, url) async {
              // Handle download start request
              // For example, you can open the download URL in a browser
              print("object want to download");
              // await launch(url);
            },
            onConsoleMessage: (controller, message) {
              print("teste" + message.toString());
            },
          ),
        ),
      ),
    );
  }
}
