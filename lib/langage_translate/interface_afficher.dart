import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextImageDisplay extends StatefulWidget {
  const TextImageDisplay({Key? key}) : super(key: key);

  @override
  State<TextImageDisplay> createState() => _TextImageDisplayState();
}

class _TextImageDisplayState extends State<TextImageDisplay> {
  String? _text;
  File? _image;

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Texte et image'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Entrez votre texte'),
                maxLines: 5,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _text = _textController.text;
                });
              },
              child: const Text('Valider le texte'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final image = await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _image = File(image.path);
                  });
                }
              },
              child: const Text('Prendre une photo'),
            ),
            const SizedBox(height: 16.0),
            if (_text != null) Text(_text!),
            if (_image != null) Image.file(_image!),
          ],
        ),
      ),
    );
  }
}
