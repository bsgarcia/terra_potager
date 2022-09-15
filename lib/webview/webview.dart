import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
//This import the package
import 'package:http/http.dart' as http;
import 'dart:developer';

//...
//Here comes code of Flutter
//...

//Now I define the async function to make the request
Future<bool> askIsLoggedIn() async{
  var response = await http.get('https://terra-potager.com/mon-compte/');
  //If the http request is successful the statusCode will be 200
  if(response.statusCode == 200){
    String htmlToParse = response.body;
    print(htmlToParse.toString().contains("Déconnexion"));
    //log(htmlToParse.toString());
    return htmlToParse.contains("Déconnexion");
  }
  return false;
}



//Future<bool> askIsLoggedIn() async {
  //return false;
//}

class WebViewExample extends StatefulWidget {
  @override
  _TerraPotagerWebView createState() => _TerraPotagerWebView();
}

class SimpleWebView extends State<WebViewExample> {

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://terra-potager.com',
    );
  }
}

class _TerraPotagerWebView extends State<WebViewExample> {
  int selectedIndex = 0;
  bool isLoading = true;
  bool isLoggedIn = false;

  // adminName and adminKey is needed only for admin level APIs
  wp.WordPress wordPress = wp.WordPress(
    baseUrl: 'https://terra-potager.com',
    authenticator: wp.WordPressAuthenticator.JWT,
    adminName: '',
    adminKey: '',
  );

  final List<String> webviewList = [
    "https://terra-potager.com",
    "https://terra-potager.com/contenus",
    "https://app.terra-potager.com/calendrier",
    "https://terra-potager.com/mon-compte",
  ];

  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    checkLogin();

  }

  void checkLogin() async {
    isLoggedIn = await askIsLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          elevation: 8,
          items:  <BottomNavigationBarItem>[
            // ignore: prefer_const_constructors
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Accueil",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded),
              label: "Contenus",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar_rounded),
              label: "Calendrier",
            ),
            BottomNavigationBarItem(
              icon: isLoggedIn ? Icon(Icons.account_box_rounded) : Icon(Icons.login_rounded),
              label: isLoggedIn ? "Profil" : "Se connecter",
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (i) async {
            isLoading = true;
            controller.loadUrl(webviewList[i]);
            setState(() => selectedIndex = i);
            String str = await controller.runJavascriptReturningResult("window.document.body.innerHTML");
            isLoggedIn = str.contains("Déconnexion");
           // if (i == webviewList.length) { isLoggedIn = await askIsLoggedIn()};
          },
        ),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 01),
          toolbarHeight: 60,
          elevation: 2,
          leading: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 200,
                minHeight: 200,
                //maxWidth: 150,
                //maxHeight: 150,
              ),
              child: Image.asset(
                  'assets/logo-terra.png') //, fit: BoxFit.cover),
          ),
        ),
        body: Stack(
          children: <Widget>[
            AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isLoading ? .1 : 1,
                child: WebView(
                  initialUrl: webviewList[selectedIndex],
                  onWebViewCreated: (c) {
                    controller = c;
                  },
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                )),
            isLoading ? Center(child: CircularProgressIndicator(),)
                : Stack(),
          ],
        ));
  }
}