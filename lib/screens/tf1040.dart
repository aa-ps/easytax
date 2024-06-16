import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TaxForm1040 extends StatefulWidget {
  const TaxForm1040({Key? key}) : super(key: key);

  @override
  State<TaxForm1040> createState() => _TaxFormState();
}

class _TaxFormState extends State<TaxForm1040> {
  String data = "";

  @override
  void initState() {
    super.initState();
    fetchFileData();
  }

  // Method to fetch file data
  void fetchFileData() async {
    String responseText =
        await rootBundle.loadString('Tax-Forms/Tax_Form1040.txt');

    setState(() {
      data = responseText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tax Form 1040',
      theme: ThemeData.dark(), // Apply dark theme to everything
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tax Form 1040'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20.0), // Add some spacing
                Image.asset(
                  'assets/images/1040.jpg',
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20.0), // Add more spacing
                Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    data,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(height: 20.0), // Add final spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const TaxForm1040());
}
