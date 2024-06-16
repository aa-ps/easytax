import 'dart:async';
import 'dart:io';
import 'package:easytax/screens/Excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PdfData extends StatefulWidget {
  const PdfData({Key? key}) : super(key: key);

  @override
  State<PdfData> createState() => _PdfDataState();
}

class _PdfDataState extends State<PdfData> {
  List<Map<String, dynamic>>? dashList;
  final Map<String, double> totalsByType = {};

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    final user = Supabase.instance.client.auth.currentUser;
    var response = await Supabase.instance.client
        .from('receipts')
        .select()
        .eq('id', user!.id);

    // Assuming that the response is correctly parsed into a List of Maps
    setState(() {
      dashList = List<Map<String, dynamic>>.from(response);
      calculateTotals();
    });
  }

  void calculateTotals() {
    // Reset totals
    totalsByType.clear();

    for (var receipt in dashList ?? []) {
      for (var item in receipt['items'] ?? []) {
        String type = item['type'] ?? 'unknown';
        double total = (item['total'] as num?)?.toDouble() ?? 0.0;

        if (!totalsByType.containsKey(type)) {
          totalsByType[type] = 0.0;
        }
        totalsByType[type] = totalsByType[type]! + total;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    calculateTotals();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt Summary"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, top: 15, right: 10),
        child: totalsByType.isNotEmpty
            ? ListView.builder(
                itemCount: totalsByType.length,
                itemBuilder: (context, index) {
                  String category = totalsByType.keys.elementAt(index);
                  double total = totalsByType.values.elementAt(index);
                  return ListTile(
                    title: Text(category),
                    trailing: Text('\$${total.toStringAsFixed(2)}'),
                  );
                },
              )
            : const Center(child: Text("No summaries found")),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {
                generateAndSaveExcel(totalsByType);
              },
              backgroundColor: const Color.fromARGB(255, 243, 245, 244),
              child: const Icon(
                Icons.insert_chart,
                color: Color.fromARGB(255, 6, 240, 68),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                printScreen();
              },
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Color.fromARGB(255, 221, 8, 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> printScreen() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.TableHelper.fromTextArray(
            context: context,
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            headerHeight: 25,
            cellHeight: 40,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
            cellStyle: const pw.TextStyle(
              fontSize: 10,
            ),
            headerStyle: const pw.TextStyle(
              fontSize: 12,
            ),
            headers: List<String>.from(['Category', 'Amount']),
            data: totalsByType.entries
                .map((entry) =>
                    [entry.key, '\$${entry.value.toStringAsFixed(2)}'])
                .toList(),
          );
        },
      ),
    );

    String? outputPath = await _pickSaveLocation();
    if (outputPath != null) {
      final File file = File(outputPath);
      await file.writeAsBytes(await pdf.save());
    }
    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );
  }

  Future<String?> _pickSaveLocation() async {
    String? outputPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Please select an output folder',
    );
    String fileName = 'output.pdf';
    String fullPath = '$outputPath/$fileName';
    return fullPath;
  }
}
