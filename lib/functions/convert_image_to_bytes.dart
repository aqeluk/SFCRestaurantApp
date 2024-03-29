import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<Uint8List> convertImageToBytes(String imagePath) async {
  // Load the image as a ui.Image object
  ByteData data = await rootBundle.load(imagePath);
  List<int> bytes = data.buffer.asUint8List();
  ui.Codec codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
  ui.FrameInfo fi = await codec.getNextFrame();

  // Convert the ui.Image to ByteData
  final ByteData? byteData =
      await fi.image.toByteData(format: ui.ImageByteFormat.png);

  // Convert ByteData to Uint8List
  return byteData!.buffer.asUint8List();
}
