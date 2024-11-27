import 'package:flutter/material.dart';
import 'linkedin/image_to_text/text_extraction_from_image.dart';

void main() => runApp(const TextExtractorApp());

class TextExtractorApp extends StatelessWidget {
  const TextExtractorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Extractor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2d68ec)),
        useMaterial3: true,
      ),
      home: const TextExtractorScreen(),
    );
  }
}
