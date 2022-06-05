import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:voice_assist/model/radio.dart';
import 'package:voice_assist/utils/ai_utils.dart';

final sugg = [
  "Play",
  "Stop",
  "Play rock music",
  "Play 107 FM",
  "Play next",
  "Play 104 FM",
  "Pause",
  "Play previous",
  "Play pop music"
];

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var connectionStatus = 0.obs;

  //bool isConnected=await InternetConnectionChecker().hasConnection;
  late StreamSubscription<InternetConnectionStatus> _listener;

  late MyRadio _currentRadio;
  late Color _currentcolor = Color(0x00FFFFFF);
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _listener = InternetConnectionChecker()
        .onStatusChange
        .listen((InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          connectionStatus.value = 1;
          break;
        case InternetConnectionStatus.disconnected:
          connectionStatus.value = 0;
          break;
      }
    });
    setupAlan();
    bring();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      _listener = InternetConnectionChecker()
        .onStatusChange
        .listen((InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          connectionStatus.value = 1;
          break;
        case InternetConnectionStatus.disconnected:
          connectionStatus.value = 0;
          break;
      }
    });
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "dcf3f9223aea8edd093447d65510e9d02e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => handleCmd(command.data));
  }

  handleCmd(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        playMusic(_currentRadio.url);
        break;
      case "play_channel":
        final id = response["id"];
        _audioPlayer.pause();
        MyRadio newRadio =
            MyRadioList.radios.firstWhere((element) => element.id == id);
        MyRadioList.radios.remove(newRadio);
        MyRadioList.radios.insert(0, newRadio);
        playMusic(newRadio.url);
        break;
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _currentRadio.id;
        MyRadio newRadio;
        if (index + 1 > MyRadioList.radios.length) {
          newRadio =
              MyRadioList.radios.firstWhere((element) => element.id == 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        } else {
          newRadio = MyRadioList.radios
              .firstWhere((element) => element.id == index + 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        }
        playMusic(newRadio.url);
        break;
      case "prev":
        final index = _currentRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio =
              MyRadioList.radios.firstWhere((element) => element.id == 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        } else {
          newRadio = MyRadioList.radios
              .firstWhere((element) => element.id == index - 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        }
        playMusic(newRadio.url);
        break;
      default:
    }
  }

  bring() async {
    final radioJson = await rootBundle.loadString("assets/files/radio.json");
    final decodedData = jsonDecode(radioJson);

    var radiosData = decodedData["radios"];

    MyRadioList.radios = List.from(radiosData)
        .map<MyRadio>((radio) => MyRadio.fromMap(radio))
        .toList();

    _currentRadio = MyRadioList.radios[0];
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
        drawer: Drawer(
          child: Container(
            color: _currentcolor != Color(0x00FFFFFF)
                ? _currentcolor
                : AIColors.primarycolor1,
            child: MyRadioList.radios != null
                ? [
                    80.heightBox,
                    "All Channels".text.xl.white.semiBold.make().px16(),
                    20.heightBox,
                    ListView(
                      padding: Vx.m0,
                      shrinkWrap: true,
                      children: MyRadioList.radios
                          .map((e) => ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(e.icon),
                                ),
                                title: "${e.name} FM".text.white.make(),
                                subtitle: e.tagline.text.white.make(),
                              ))
                          .toList(),
                    ).expand()
                  ].vStack(crossAlignment: CrossAxisAlignment.start)
                : const Offstage(),
          ),
        ),
        body: Obx(() => connectionStatus.value == 1
            ? Stack(
                children: [
                  VxAnimatedBox()
                      .size(context.screenWidth, context.screenHeight)
                      .withGradient(LinearGradient(colors: [
                        AIColors.primarycolor2,
                        _currentcolor != Color(0x00FFFFFF)
                            ? _currentcolor
                            : AIColors.primarycolor1
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight))
                      .make(),
                  [
                    AppBar(
                      title: "Radio".text.white.xl3.bold.make().shimmer(),
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      centerTitle: true,
                    ).h(90).p(16),
                    20.heightBox,
                    VxSwiper.builder(
                        itemCount: sugg.length,
                        height: 50,
                        viewportFraction: 0.35,
                        autoPlay: true,
                        autoPlayAnimationDuration: 3.seconds,
                        autoPlayCurve: Curves.linear,
                        enableInfiniteScroll: true,
                        itemBuilder: (context, index) {
                          final s = sugg[index];
                          return Chip(
                            label: s.text.make(),
                            backgroundColor: Vx.randomColor,
                          );
                        })
                  ].vStack(),
                  MyRadioList.radios != null
                      ? VxSwiper.builder(
                          itemCount: MyRadioList.radios.length,
                          aspectRatio:
                              context.mdWindowSize == VxWindowSize.xsmall
                                  ? 1.0
                                  : context.mdWindowSize == VxWindowSize.medium
                                      ? 2.0
                                      : 3.0,
                          onPageChanged: (index) {
                            _currentRadio = MyRadioList.radios[index];
                            final colorhex = MyRadioList.radios[index].color;

                            _currentcolor =
                                Color(int.parse(colorhex, radix: 16));

                            print(int.parse(colorhex, radix: 16));

                            setState(() {});
                          },
                          enlargeCenterPage: true,
                          itemBuilder: (context, index) {
                            final rad = MyRadioList.radios[index];

                            return VxBox(
                                    child: ZStack([
                              Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: VxBox(
                                        child: rad.category.text.uppercase.white
                                            .make()
                                            .px(16))
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
                                          Colors.black.withOpacity(0.3),
                                          BlendMode.darken)),
                                )
                                .withRounded(value: 60.0)
                                .border(color: Colors.black, width: 4.0)
                                .make()
                                .onInkTap(() {
                              playMusic(rad.url);
                            }).p(16);
                          },
                        ).centered()
                      : Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: [
                      if (_isPlaying)
                        "Playing Now - ${_currentRadio.name} FM"
                            .text
                            .makeCentered(),
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
              )
            : SingleChildScrollView(
                child: "Connect To Internet".text.black.xl4.make(),
                
              ).centered(),
              
              )
              );
  }
}
