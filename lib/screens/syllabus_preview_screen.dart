// ================================
// 📄 Syllabus Preview Screen (Now with ReviewEventsScreen navigation)
// ================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../calendar/calendar_repository.dart';
import '../calendar/calendar_event.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:xml/xml.dart';
import 'review_events_screen.dart';
import 'dart:convert';


class SyllabusPreviewScreen extends StatefulWidget {
  const SyllabusPreviewScreen({super.key});

  @override
  State<SyllabusPreviewScreen> createState() => _SyllabusPreviewScreenState();
}

class _SyllabusPreviewScreenState extends State<SyllabusPreviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _parsedEvents = [];
  final CalendarRepository _calendarRepo = CalendarRepository();

  void _parseText() {
    final raw = _controller.text;
    final parsed = SyllabusParser.extractEvents(raw);
    if (parsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No events were found in the text.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewEventsScreen(parsedEvents: parsed),
      ),
    );
  }

  Future<void> _pickFileAndExtractText() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      String extracted = '';

      if (path.endsWith('.pdf')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ PDF parsing not supported yet. Please upload a DOCX file.')),
        );
        return;
      } else if (path.endsWith('.docx')) {
        try {
          final bytes = File(path).readAsBytesSync();
          final archive = ZipDecoder().decodeBytes(bytes);
          final docFile = archive.firstWhere((f) => f.name == 'word/document.xml');
          final xmlString = utf8.decode(docFile.content as List<int>);
          final document = XmlDocument.parse(xmlString);
          extracted = document.findAllElements('w:t').map((e) => e.innerText).join(' ');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reading DOCX file: $e')),
          );
          return;
        }
      }

      setState(() => _controller.text = extracted);
      _parseText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📄 Syllabus Preview")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFileAndExtractText,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Syllabus (.docx only)"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Paste syllabus text or upload a DOCX file...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _parseText,
              icon: const Icon(Icons.preview),
              label: const Text("Review Parsed Events"),
            ),
          ],
        ),
      ),
    );
  }
}

class SyllabusParser {
  static final RegExp _linePattern = RegExp(
    r'(?:(\w+\s\d{1,2}(?:,\s*\d{4})?)|(\d{1,2}/\d{1,2}(?:/\d{2,4})?))\s*[-–—]\s*(.+)',
    caseSensitive: false,
  );

  static String _preprocess(String line) {
    return line
      .replaceAll(',', '')
      .replaceAll(RegExp(r'(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)', caseSensitive: false), '')
      .trim();
  }

  static List<Map<String, dynamic>> extractEvents(String rawText) {
    final lines = rawText.split(RegExp(r'(\\n|\\r|\\t|\\s{2,})+')).where((line) => line.trim().isNotEmpty).toList();
    final List<Map<String, dynamic>> events = [];

    for (var line in lines) {
      final cleaned = _preprocess(line);
      if (cleaned.length < 6) continue;
      final match = _linePattern.firstMatch(cleaned);
      if (match != null) {
        final datePart = match.group(1) ?? match.group(2);
        final title = match.group(3)?.trim();

        final parsedDate = _parseDate(datePart);
        if (parsedDate != null && title != null) {
          events.add({
            'title': title,
            'date': parsedDate,
          });
        }
      }
    }

    return events;
  }

  static DateTime? _parseDate(String? input) {
    if (input == null) return null;
    final now = DateTime.now();

    try {
      if (input.contains('/')) {
        final parts = input.split('/');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = (parts.length == 3) ? int.parse(parts[2]) : now.year;
        return DateTime(year, month, day);
      }

      final formats = [
        "MMMM d yyyy",
        "MMMM d",
        "MMM d yyyy",
        "MMM d",
        "d MMMM yyyy",
        "d MMM yyyy"
      ];

      for (final format in formats) {
        try {
          final date = DateFormat(format).parseStrict(input);
          return DateTime(now.year, date.month, date.day);
        } catch (_) {
          continue;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
