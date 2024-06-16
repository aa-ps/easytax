import 'package:flutter/material.dart';
import 'package:easytax/screens/tf1040.dart';
import 'package:easytax/screens/tf1041.dart';
import 'package:easytax/screens/tf1040C.dart';
import 'package:easytax/screens/tf1040D.dart';
import 'package:easytax/screens/tf1040E.dart';
import 'package:easytax/screens/tf1040F.dart';
import 'package:easytax/screens/tf1040SR.dart';

void main() {
  runApp(const MaterialApp(
    home: TaxInformationScreen(),
  ));
}

class TaxInformationScreen extends StatelessWidget {
  const TaxInformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Form Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTaxFormButton(context, "Tax Form 1040", () {
              _navigateTo(context, const TaxForm1040());
            }),
            const SizedBox(height: 20),
            _buildTaxFormButton(context, "Tax Form 1041", () {
              _navigateTo(context, const TaxForm1041());
            }),
            const SizedBox(height: 20),
            _buildTaxFormButton(context, "Tax Form 1040-SR", () {
              _navigateTo(context, const TaxForm1040_SR());
            }),
            const SizedBox(height: 20),
            _buildTaxFormButton(context, "1040 Schedule-C", () {
              _navigateTo(context, const TaxForm1040C());
            }),
            const SizedBox(height: 20),
            _buildTaxFormButton(context, "1040 Schedule-E", () {
              _navigateTo(context, const TaxForm1040E());
            }),
            const SizedBox(height: 20),
            _buildTaxFormButton(context, "1040 Schedule-D", () {
              _navigateTo(context, const TaxForm1040D());
            }),
            const SizedBox(height: 20),
            _buildTaxFormButton(context, "1040 Schedule-F", () {
              _navigateTo(context, const TaxForm1040F());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxFormButton(
      BuildContext context, String buttonText, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        minimumSize: const Size(200, 0),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
