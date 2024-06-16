import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:io';
import 'dart:async';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';

Future<void> generateAndSaveExcel(Map<String, double> totalsByType) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  // Set the header text.
  sheet.getRangeByIndex(1, 1).setText('Categories');
  sheet.getRangeByIndex(1, 2).setText('Total');

  int rowIndex = 2;
  for (final entry in totalsByType.entries) {
    sheet.getRangeByIndex(rowIndex, 1).setText(entry.key);
    sheet.getRangeByIndex(rowIndex, 2).setNumber(entry.value);
    rowIndex++;
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  try {
    String? outputPath = await _pickSaveLocation();
    if (outputPath != null && outputPath.isNotEmpty) {
      final File file = File(outputPath);
      await file.writeAsBytes(bytes, flush: true);
      await OpenFile.open(outputPath);
    } else {
      debugPrint('User canceled save dialog.');
    }
  } catch (e) {
    debugPrint('An error occurred while saving the file: $e');
  }
}

// Allow user to choose save location
Future<String?> _pickSaveLocation() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Please select an output folder');
  
  if (selectedDirectory == null) {
    // User canceled the picker
    return null;
  }

  String fileName = 'output.xlsx'; 
  String fullPath = '$selectedDirectory/$fileName';
  return fullPath;
}
