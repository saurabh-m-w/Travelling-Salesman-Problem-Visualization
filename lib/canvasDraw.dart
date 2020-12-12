

import 'dart:ui';

import 'package:flutter/material.dart';

class FaceOutlinePainter extends CustomPainter {

  final List<List<double>> cities;
  final List<List<double>> citiespt;

  FaceOutlinePainter({this.citiespt,this.cities});

  PointMode pt=PointMode.lines;

  @override
  void paint(Canvas canvas, Size size) async{

    final pt=PointMode.points;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    final ptclor=Paint()
      ..color = Colors.blue
      ..strokeWidth=8;

    for(dynamic i=0;i<citiespt.length;i++)
    {
      canvas.drawPoints(pt,[Offset(citiespt[i][0],citiespt[i][1])],ptclor);
      canvas.drawCircle(Offset(citiespt[i][0],citiespt[i][1]), 6, ptclor);
    }
    for(dynamic i=1;i<cities.length;i++)
    {
      canvas.drawLine(Offset(cities[i-1][0],cities[i-1][1]),Offset(cities[i][0],cities[i][1]),paint);
    }

  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => true;
}