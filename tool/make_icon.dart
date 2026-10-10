import 'dart:io';
import 'package:image/image.dart' as img;

/// Crops the logo to its visible mark and centres it on a 1024x1024 white square.
/// Run from the project root: dart run tool/make_icon.dart
void main() {
  final file = File('assets/icon/logo.jpg');
  if (!file.existsSync()) {
    stderr.writeln('Could not find assets/icon/logo.jpg');
    exit(1);
  }

  final src = img.decodeImage(file.readAsBytesSync());
  if (src == null) {
    stderr.writeln('Could not read the image.');
    exit(1);
  }

  // 1. Find the bounding box of every non-white pixel.
  var minX = src.width, minY = src.height, maxX = 0, maxY = 0;
  for (final p in src) {
    final brightness = (p.r + p.g + p.b) / 3;
    if (brightness < 200) {
      if (p.x < minX) minX = p.x.toInt();
      if (p.y < minY) minY = p.y.toInt();
      if (p.x > maxX) maxX = p.x.toInt();
      if (p.y > maxY) maxY = p.y.toInt();
    }
  }

  final w = maxX - minX + 1;
  final h = maxY - minY + 1;
  final mark = img.copyCrop(src, x: minX, y: minY, width: w, height: h);

  // 2. Scale so the longest side is 600px (about 59% of the canvas).
  //    Android's adaptive icon mask only guarantees the centre ~66% is visible.
  const canvasSize = 1024;
  const markSize = 600;
  final resized = w >= h
      ? img.copyResize(mark, width: markSize, interpolation: img.Interpolation.cubic)
      : img.copyResize(mark, height: markSize, interpolation: img.Interpolation.cubic);

  // 3. Centre it on a white square.
  final canvas = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(
    canvas,
    resized,
    dstX: (canvasSize - resized.width) ~/ 2,
    dstY: (canvasSize - resized.height) ~/ 2,
  );

  File('assets/icon/logo.png').writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('Done: assets/icon/logo.png (${resized.width}x${resized.height} mark)');
}