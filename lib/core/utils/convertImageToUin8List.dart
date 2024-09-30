import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List convertImageToUint8List(img.Image image) {
  // Encode the image to PNG format
  final List<int> pngBytes = img.encodePng(image);

  // Convert the List<int> to Uint8List
  final Uint8List uint8List = Uint8List.fromList(pngBytes);


  return uint8List;
}