import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  runApp(const CryptoText());
}

class CryptoText extends StatelessWidget {
  const CryptoText({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CryptoText',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  //kunci untuk enkripsi dan deskripsi
  final encrypt.Key _key = encrypt.Key.fromLength(32);

  //Initialization Vector untuk enkripsi dan deskripsi
  final iv = encrypt.IV.fromLength(16);

  String _encryptedText = '';
  String _decryptedText = '';
  String? _erorText;
  bool _isDecryptButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CryptoText'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Input Text',
                errorText: _erorText,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onTextChanged,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String inputText = _textEditingController.text;

                if (inputText.isNotEmpty) {
                  _encryptText(inputText);
                } else {
                  setState(() {
                    _erorText = 'Input cannot be empty';
                  });
                }
              },
              child: const Text('Encrypt'),
            ),
            const SizedBox(height: 10),
            Text(
              'Encrypted text : $_encryptedText',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isDecryptButtonEnabled && _encryptedText.isNotEmpty
                  ? () {
                      String inputText = _encryptedText;
                      final encrypted = encrypt.Encrypted.fromBase64(inputText);
                      _decryptText(encrypted.base64);
                    }
                  : null,
              child: const Text('Decrypt'),
            ),
            const SizedBox(height: 10),
            Text(
              'Decrypted text : $_decryptedText',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _onTextChanged(String text) {
    setState(() {
      _isDecryptButtonEnabled = text.isNotEmpty;
      _encryptedText = '';
      _decryptedText = '';
      _erorText = null;
    });
  }

  void _encryptText(String text) {
    try {
      if (text.isNotEmpty) {
        final encrypter = encrypt.Encrypter(encrypt.AES(_key));
        final encrypted = encrypter.encrypt(text, iv: iv);
        setState(() {
          _encryptedText = encrypted.base64;
        });
      } else {
        print('Text to encrypt cannot be empty');
      }
    } catch (e, stackTrace) {
      print('Eror encrypting text : $e, stackTrace: $stackTrace');
    }
  }

  void _decryptText(String text) {
    try {
      if (text.isNotEmpty) {
        final encrypter = encrypt.Encrypter(encrypt.AES(_key));
        final decrypted = encrypter.decrypt64(text, iv: iv);

        setState(() {
          _decryptedText = decrypted;
        });
      } else {
        print('Text to decrypt cannot be empty');
      }
    } catch (e, stackTrace) {
      print('Eror decrypting text : $e, stackTrace : $stackTrace');
    }
  }
}
