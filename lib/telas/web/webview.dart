import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../componentes/voltar.dart';
import '../../tema/cores.dart';
import '../erro/erro.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  InAppWebViewController? _webViewController;
  PullToRefreshController? _refreshController;

  bool _isLoading = false, _isVisible = false, _isOffline = false;

  int _errorCode = 0;
  final BackPressed _backPressed = BackPressed();

  Future<void> checkError() async {

    _isLoading = false;

    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result != ConnectivityResult.none) {
      if (_isOffline == true) {
        _isVisible = false;
        _isOffline = false;
      }
    }

    else {
      _errorCode = 0;
      _isOffline = true;
      _isVisible = true;
    }


    if (_errorCode == 1) _isVisible = false;
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat();
    _refreshController = PullToRefreshController(
      onRefresh: () => _webViewController!.reload(),
      settings: PullToRefreshSettings(
          color: Colors.white, backgroundColor: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InAppWebView(
                  onWebViewCreated: (controller) =>
                  _webViewController = controller,
                    initialSettings: InAppWebViewSettings(
                    mediaPlaybackRequiresUserGesture: false,
                    useHybridComposition: true,
                    allowsInlineMediaPlayback: true,
                  ),
                  initialUrlRequest: URLRequest(
                      url: WebUri(
                          "https://br-newsdroid.blogspot.com")),
                  pullToRefreshController: _refreshController,
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) {
                    _refreshController!.endRefreshing();
                    checkError();
                  },
                  onLoadError: (controller, url, code, message) {

                    _errorCode = code;
                    _isVisible = true;
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    _errorCode = statusCode;
                    _isVisible = true;
                  },
                ),

                Visibility(
                  visible: _isVisible,
                  child: ErrorScreen(
                      isOffline: _isOffline,
                      onPressed: () {
                        _webViewController!.reload();
                        if (_errorCode != 0) {
                          _errorCode = 1;
                        }
                      }),
                ),
                //CircularProgressIndicator
                Visibility(
                  visible: _isLoading,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: _animationController.drive(
                      ColorTween(
                          begin: circularProgressBegin,
                          end: circularProgressEnd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (await _webViewController!.canGoBack()) {
            await _webViewController!.goBack();
            return false;
          } else {
            return _backPressed.exit(context);
          }
        });
  }
}
