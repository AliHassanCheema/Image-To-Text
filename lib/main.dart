import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

void main() => runApp(const TextExtractorApp());

class TextExtractorApp extends StatelessWidget {
  const TextExtractorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Extractor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2d68ec)),
        useMaterial3: true,
      ),
      home: const TextExtractorScreen(),
    );
  }
}

class TextExtractorScreen extends StatefulWidget {
  const TextExtractorScreen({super.key});

  @override
  TextExtractorScreenState createState() => TextExtractorScreenState();
}

class TextExtractorScreenState extends State<TextExtractorScreen> {
  File? _selectedImage;
  String _extractedText = "";
  bool _isProcessing = false;

  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _extractedText = "";
      });
      _extractText();
    }
  }

  Future<void> _extractText() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    final inputImage = InputImage.fromFile(_selectedImage!);

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = "Error extracting text: $e";
        _isProcessing = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_extractedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copied to clipboard")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Text'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_extractedText.isNotEmpty)
              Expanded(
                child: Card(
                  margin: const EdgeInsets.only(top: 16),
                  color: const Color(0xffE8F0FE),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Extracted Text",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff2D68EC),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _copyToClipboard,
                                icon: const Icon(Icons.copy),
                                color: const Color(0xff2D68EC),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _extractedText,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_selectedImage == null)
              Expanded(
                child: Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceDialog(),
        backgroundColor: const Color(0xff2D68EC),
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            iconColor: const Color(0xff2D68EC),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            iconColor: const Color(0xff2D68EC),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }
}
