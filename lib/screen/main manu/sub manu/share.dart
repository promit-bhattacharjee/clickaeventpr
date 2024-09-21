import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class Share extends StatefulWidget {
  const Share({super.key});

  @override
  State<Share> createState() => _ShareState();

  static share(String s) {}


}

class _ShareState extends State<Share> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async{
           await Share.share('Share');
          }, child: const Text('Share App'),
        ),
      ),
    );
  }
}

// void sharePresssd(){
//   String massage ="Jakir Hossen";
//   Share.share(massage);
// }
