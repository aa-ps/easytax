import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TaxForm1040D extends StatefulWidget {
  const TaxForm1040D({Key? key}) : super(key: key);

  @override
  State<TaxForm1040D> createState() => _TaxFormDState();
}

class _TaxFormDState extends State<TaxForm1040D> {
  String data = "";

  fetchFileData() async {
    String responseText =
        await rootBundle.loadString('Tax-Forms/1040_Sch_D.txt');

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
      title: '1040 Schedule-D',
      theme: ThemeData.dark(), // Apply dark theme to everything
      home: Scaffold(
        appBar: AppBar(
          title: const Text('1040 Schedule-D'),
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
                  'assets/images/1040D.jpg',
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
  runApp(const TaxForm1040D());
}
