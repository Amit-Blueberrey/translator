// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:crypto/crypto.dart';


// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Encryption Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final Map<String, String> data = {
//     "mac_address": "M:M:M:S:S:S",
//     "total_channels": "4",
//     "speed_control_channels": "1",
//     "product_id": "2812ER44",
//   };
  
//   String encryptedData = '';
//   String decryptedData = '';

//   final String encryptionKey = 'your-encryption-key-here';

//   String encrypt(String plainText, String key) {
//     final keyBytes = utf8.encode(key);
//     final bytes = utf8.encode(plainText);
//     final hmacSha256 = Hmac(sha256, keyBytes);
//     final digest = hmacSha256.convert(bytes);
//     return base64Url.encode(digest.bytes);
//   }

//   String decrypt(String encryptedText, String key) {
//     // Since we're using HMAC which is a one-way hash, we can't actually decrypt it.
//     // So we'll just return the original text here.
//     return encryptedText;
//   }

//   void generateQRCode() {
//     setState(() {
//       final jsonString = jsonEncode(data);
//       encryptedData = encrypt(jsonString, encryptionKey);
//     });
//   }

//   Future<void> scanQRCode() async {
//     final scannedQRCode = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const SimpleBarcodeScannerPage(),
//       ),
//     );

//     if (scannedQRCode != null && scannedQRCode != '-1') {
//       setState(() {
//         decryptedData = decrypt(scannedQRCode, encryptionKey);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Encryption Demo'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: generateQRCode,
//               child: Text('Generate QR Code'),
//             ),
//             SizedBox(height: 16.0),
//             if (encryptedData.isNotEmpty)
//               PrettyQr(
//                 data: encryptedData,
//                 size: 200.0,
//                 roundEdges: true,
//               ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: scanQRCode,
//               child: Text('Scan QR Code'),
//             ),
//             SizedBox(height: 16.0),
//             if (decryptedData.isNotEmpty)
//               Text('Decrypted Data: $decryptedData'),
//           ],
//         ),
//       ),
//     );
//   }
// }
