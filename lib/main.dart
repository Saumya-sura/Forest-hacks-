import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Text Summarizer',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: PdfTextSummarizer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PdfTextSummarizer extends StatefulWidget {
  @override
  _PdfTextSummarizerState createState() => _PdfTextSummarizerState();
}

class _PdfTextSummarizerState extends State<PdfTextSummarizer> {
  String? _summary;
  bool _isLoading = false;

  Future<void> _pickAndExtractPdf() async {
    setState(() {
      _isLoading = true;
      _summary = null;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
     
      String filePath = result.files.single.path!;
      await _extractTextFromPdf(filePath);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _extractTextFromPdf(String path) async {
    try {
      final File file = File(path);
      final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());

      String extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      setState(() {
        _summary = extractedText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _summary = 'Error extracting text: $e';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_summary != null && _summary!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _summary!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Text Summarizer'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _pickAndExtractPdf,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _summary == null
              ? Center(
                  child: Text(
                    'Select a PDF to extract text',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _summary!,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: Icon(Icons.copy),
                        label: Text('Copy to Clipboard'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
