import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SettingPage extends StatefulWidget {
  final DatabaseReference? databaseReference;
  final String? id;

  SettingPage({this.databaseReference, this.id});

  @override
  State<StatefulWidget> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  bool pushCheck = true;

  BannerAd? _banner;
  bool _loadingBanner = false;

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );
    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }
    final BannerAd banner = BannerAd(
      size: size,
      request: AdRequest(),
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _banner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  @override
  void dispose() {
    super.dispose();
    _banner!.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingBanner) {
      _loadingBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('설정하기'),
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '푸시 알림',
                        style: TextStyle(fontSize: 20),
                      ),
                      Switch(
                          value: pushCheck,
                          onChanged: (value) {
                            setState(() {
                              pushCheck = value;
                            });
                            _setData(value);
                          })
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                    },
                    child: Text('로그아웃', style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AlertDialog dialog = new AlertDialog(
                        title: Text('아이디 삭제'),
                        content: Text('아이디를 삭제하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                print(widget.id);
                                widget.databaseReference!
                                    .child('user')
                                    .child(widget.id!)
                                    .remove();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/', (Route<dynamic> route) => false);
                              },
                              child: Text('예')),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('아니요')),
                        ],
                      );
                      showDialog(
                          context: context,
                          builder: (context) {
                            return dialog;
                          });
                    },
                    child: Text('회원 탈퇴', style: TextStyle(fontSize: 20)),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ),
          if (_banner != null)
            Container(
              color: Colors.green,
              width: _banner!.size.width.toDouble(),
              height: _banner!.size.height.toDouble(),
              child: AdWidget(ad: _banner!),
            )
        ],
      )
    );
  }

  void _setData(bool value) async {
    var key = "push";
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  void _loadData() async {
    var key = "push";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      var value = pref.getBool(key);
      if (value == null) {
        setState(() {
          pushCheck = true;
        });
      } else {
        setState(() {
          pushCheck = value;
        });
      }
    });
  }
}
