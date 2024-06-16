import 'dart:typed_data';
import 'package:easytax/main.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageProcessingScreen extends StatefulWidget {
  final XFile imageTaken;

  const ImageProcessingScreen({Key? key, required this.imageTaken})
      : super(key: key);

  @override
  _ImageProcessingScreenState createState() => _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends State<ImageProcessingScreen> {
  Uint8List? imageBytes;
  String imgExt = '';
  String imgName = '';
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initImageProperties();
    cropImage();
  }

  Future<void> initImageProperties() async {
    imgExt = widget.imageTaken.name.split('.').last;
    imgName = '${DateTime.now().toIso8601String()}.$imgExt';
    final bytes = await widget.imageTaken.readAsBytes();
    setState(() {
      imageBytes = bytes;
    });
  }

  Future<void> cropImage() async {
    ImageCropper().cropImage(
        sourcePath: widget.imageTaken.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Receipt',
            toolbarColor: Theme.of(context).colorScheme.background,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ]).then((croppedFile) {
      if (croppedFile != null) {
        croppedFile.readAsBytes().then((bytes) {
          setState(() => imageBytes = bytes);
        });
      }
    });
  }

  Future<http.Response> processReceipt(String imgUrl) async {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'CLIENT-ID': 'VERYFI_CLIENT_ID',
      'AUTHORIZATION': 'VERYFI_AUTH',
    };

    // Set up request body
    final body = json.encode({
      'file_url': imgUrl,
    });

    // Make the POST request
    try {
      return await http.post(
        Uri.parse('https://api.veryfi.com/api/v8/partner/documents'),
        headers: headers,
        body: body,
      );
    } catch (e) {
      debugPrint('Error sending receipt to API: $e');
      throw Exception('Failed to process receipt.');
    }
  }

  Map<String, dynamic> processItems(apiData) {
    if (!apiData.containsKey('line_items')) {
      throw Exception('The given data does not contain "line_items"');
    }

    List<dynamic> rawItems = apiData['line_items'];
    List<Map<String, dynamic>> items = [];
    double totalSum = 0.0;

    for (var rawItem in rawItems) {
      Map<String, dynamic> item = {
        'description': rawItem['description'].replaceAll("\n", " "),
        'total': rawItem['total'],
        'quantity': rawItem['quantity'],
        'type': rawItem['type'],
      };

      items.add(item);
      totalSum += double.tryParse(rawItem['total'].toString()) ?? 0.0;
    }

    return {
      'items': items,
      'totalSum': totalSum,
    };
  }

  void showProcessingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Material(
              child: PopScope(
                  canPop: !isProcessing,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Processing Receipt...'),
                      ],
                    ),
                  )),
            ));
  }

  void showErrorDialog(Exception e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('An error occurred: ${e.toString()}'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleProcessReceipt() async {
    final currentUserID = supabase.auth.currentUser?.id;
    if (!isProcessing && imageBytes != null && currentUserID != null) {
      setState(() => isProcessing = true);
      showProcessingDialog();

      try {
        // Upload image
        final storageResponse = await supabase.storage
            .from('receipts/$currentUserID')
            .uploadBinary(imgName, imageBytes!,
                fileOptions:
                    FileOptions(contentType: widget.imageTaken.mimeType));


        // Get the URL for the image stored
        final imageUrl = supabase.storage
            .from('receipts/$currentUserID')
            .getPublicUrl(imgName);


        // Send the image to the API
        final apiResponse = await processReceipt(imageUrl);
        final apiData = json.decode(apiResponse.body);
        debugPrint(apiResponse.body.toString());
        final processedItems = processItems(apiData);

        // Insert the API data into a new row in receipts table
        final insertResponse = await supabase.from('receipts').insert({
          'id': currentUserID,
          'image_url': imageUrl,
          'data': apiData,
          'items': processedItems["items"],
          'total': processedItems["totalSum"],
        });

      } on Exception catch (e) {
        debugPrint('Error during receipt processing: $e');
        showErrorDialog(e);
      } finally {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/dashboard', ModalRoute.withName('/main'));
      }

      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Processing'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.crop),
            onPressed: !isProcessing ? () => cropImage() : null,
          ),
        ],
      ),
      body: Center(
        child: imageBytes == null
            ? const CircularProgressIndicator()
            : InkWell(
                onTap: !isProcessing
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.5,
                              maxScale: 5.0,
                              child: Image.memory(imageBytes!,
                                  fit: BoxFit.contain),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Image.memory(
                  imageBytes!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: !isProcessing ? _handleProcessReceipt : null,
        tooltip: 'Process Receipt',
        heroTag: "Receipt Processor Button",
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
