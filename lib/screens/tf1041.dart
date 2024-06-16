import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TaxForm1041 extends StatefulWidget {
  const TaxForm1041({Key? key}) : super(key: key);

  @override
  State<TaxForm1041> createState() => _TaxForm1041State();
}

class _TaxForm1041State extends State<TaxForm1041> {
  String data = "";

  fetchFileData() async {
    String responseText =
        await rootBundle.loadString('Tax-Forms/Tax_Form1041.txt');

    setState(() {
      data = responseText;
    });
  }

  @override
  void initState() {
    fetchFileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tax Form 1041',
      theme: ThemeData.dark(), // Apply dark theme to everything
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tax Form 1041'),
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
                  'assets/images/1041.jpg',
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
  runApp(const TaxForm1041());
}
