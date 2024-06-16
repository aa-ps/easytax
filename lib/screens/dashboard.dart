import 'dart:math';
import 'package:easytax/screens/Pdf.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:easytax/screens/profile.dart';
import 'package:easytax/screens/receipt.dart';
import 'package:easytax/main.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  late final Stream<List<Map<String, dynamic>>> stream;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    stream = supabase
        .from('receipts')
        .stream(primaryKey: ["id"])
        .eq('id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PdfData())),
            tooltip: 'Export Data',
          ),
          IconButton(
            iconSize: 36,
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return DashboardContent(receipts: snapshot.data!);
            }
            return const Center(child: Text("No receipts found"));
          },
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final List<Map<String, dynamic>> receipts;

  static const List<Color> distinctColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lime,
    Colors.lightBlue,
  ];

  const DashboardContent({Key? key, required this.receipts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build UI based on updated `receipts` data
    Map<String, double> typeTotals = {};

    for (var receipt in receipts) {
      if (receipt['items'] != null) {
        for (var item in receipt['items']) {
          String type = item['type'] ?? 'unknown';
          double total = (item['total'] as num?)?.toDouble() ?? 0.0;
          typeTotals.update(type, (value) => value + total,
              ifAbsent: () => total);
        }
      }
    }

    List<PieChartSectionData> pieChartSections =
        typeTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}:', // Legend text
        color: distinctColors[typeTotals.keys.toList().indexOf(entry.key) %
            distinctColors.length],
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
        showTitle: false, // Hide the labels
      );
    }).toList();

    double totalSum = typeTotals.values
        .fold(0.0, (previousValue, element) => previousValue + element);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DashboardItem(
                title: 'Scans',
                value: '${receipts.length}',
                valueFontSize: 20,
              ),
              const SizedBox(width: 20),
              DashboardItem(
                title: 'Total Amount',
                value: '\$${totalSum.toStringAsFixed(2)}',
                valueFontSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 500,
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: pieChartSections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: pieChartSections.map((section) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: section.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${section.title} \$${section.value.toStringAsFixed(2)}', // Legend with value
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receiptData = receipts[index];
              final Receipt receipt = Receipt(
                createdAt: DateTime.parse(receiptData["created_at"]),
                data: receiptData["data"],
                imageUrl: receiptData["image_url"],
                receiptId: receiptData["receipt_id"],
                items: receiptData["items"],
                total: receiptData["total"].toDouble(),
              );

              final totalAmount = receipt.total;
              final dateFormat = DateFormat.yMMMd().add_Hm();

              return Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: receipt.imageUrl,
                      height: 56.0,
                      width: 56.0,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.error_outline),
                    ),
                  ),
                  title: Text(
                    '\$$totalAmount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    dateFormat.format(receipt.createdAt.toLocal()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptScreen(receipt: receipt),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final String title;
  final String value;
  final double valueFontSize;

  const DashboardItem({
    Key? key,
    required this.title,
    required this.value,
    this.valueFontSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: valueFontSize),
            ),
          ],
        ),
      ),
    );
  }
}
