// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class MyRadioList {
     static List<MyRadio> radios = [
       MyRadio(
               id: 1,
               name: "92.7",
               tagline: "Suno Sunao, Life Banao!",
               color: "ffa11431",
               desc: "The chills you get when you listen to music, is mostly caused by the brain releasing dopamine while anticipating the peak moment of a song.",
               url: "https://node-14.zeno.fm/cm1fkgbv1ceuv?rj-ttl=5&rj-token=AAABa7Pm__WhrF8jIJ36of_AC5C-TeMcqPiHC5BJB1j1JxkowiWAyQ;",
               icon: "https://mytuner.global.ssl.fastly.net/media/tvos_radios/m8afyszryaqt.png",
               image: "https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/b5df4c18876369.562d0d4bd94cf.jpg",
               lang: "Hindi",
               category: "pop",
               order: 1
       )
     ];
  }

class MyRadio {
  final int id;
  final int order;
  final String name;
  final String tagline;
  final String color;
  final String desc;
  final String url;
  final String category;
  final String icon;
  final String image;
  final String lang;
  MyRadio(
      {required this.id,
      required this.order,
      required this.name,
      required this.tagline,
      required this.color,
      required this.desc,
      required this.url,
      required this.category,
      required this.icon,
      required this.image,
      required this.lang,});

  factory MyRadio.fromMap(Map<String, dynamic> map) {
    return MyRadio(
      id: map["id"],
      order: map["order"],
      name: map["name"],
      tagline: map["tagline"],
      color: map["color"],
      desc: map["desc"],
      url: map["url"],
      category: map["category"],
      icon: map["icon"],
      image: map["image"],
      lang: map["lang"],
    );
  }

  toMap() => {
        "id": id,
        "order":order,
        "name": name,
        "tagline": tagline,
        "color": color,
        "desc": desc,
        "url":url,
        "category":category,
        "icon":icon,
        "image": image,
        "lang":lang,
      };
}