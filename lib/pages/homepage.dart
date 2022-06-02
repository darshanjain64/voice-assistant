import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:voice_assist/model/radio.dart';
import 'package:voice_assist/utils/ai_utils.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late MyRadio _currentRadio;
  late Color _currentcolor;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    bring();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  bring() async {
    final radioJson = await rootBundle.loadString("assets/files/radio.json");
    final decodedData = jsonDecode(radioJson);

    var radiosData = decodedData["radios"];

    MyRadioList.radios = List.from(radiosData)
        .map<MyRadio>((radio) => MyRadio.fromMap(radio))
        .toList();

    setState(() {});
  }

  playMusic(String url) {
    _audioPlayer.play(url);
    _currentRadio =
        MyRadioList.radios.firstWhere((element) => element.url == url);
    print(_currentRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient(LinearGradient(
                    colors: [AIColors.primarycolor1, AIColors.primarycolor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight))
                .make(),
            AppBar(
              title: "Radio".text.white.xl3.bold.make().shimmer(),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(90).p(16),
            MyRadioList.radios!=null?VxSwiper.builder(
              itemCount: MyRadioList.radios.length,
              aspectRatio: 1.0,
              enlargeCenterPage: true,
              itemBuilder: (context, index) {
                final rad = MyRadioList.radios[index];

                return VxBox(
                        child: ZStack([
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: VxBox(
                            child:
                                rad.category.text.uppercase.white.make().px(16))
                        .height(40)
                        .black
                        .withRounded(value: 10)
                        .alignCenter
                        .make(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: VStack(
                      [
                        rad.tagline.text.white.xl2.make(),
                        15.heightBox,
                      ],
                      crossAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      CupertinoIcons.play_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                  )
                ]))
                    .clip(Clip.antiAlias)
                    .bgImage(
                      DecorationImage(
                          image: NetworkImage(rad.image),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3), BlendMode.darken)),
                    )
                    .withRounded(value: 60.0)
                    .border(color: Colors.black, width: 4.0)
                    .make()
                    .onInkTap(() {
                  playMusic(rad.url);
                }).p(16);
              },
            ).centered()
            :Center(child: CircularProgressIndicator(color: Colors.white),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (_isPlaying)
                  "Playing Now - ${_currentRadio.name} FM".text.makeCentered(),
                Icon(
                  _isPlaying
                      ? CupertinoIcons.stop_circle
                      : CupertinoIcons.play_circle,
                  color: Colors.white,
                  size: 32,
                ).onInkTap(() {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    playMusic(_currentRadio.url);
                  }
                })
              ].vStack(),
            ).pOnly(bottom: context.percentHeight * 15)
          ],
          fit: StackFit.expand,
        ));
  }
}
