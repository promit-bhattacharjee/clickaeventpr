//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../../style/style.dart';
// import '../../onborading/login_screen.dart';
//
// class Navbar extends StatelessWidget {
//   const Navbar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           UserAccountsDrawerHeader(
//             accountName: const Text("Minhaj Mahim"),
//             accountEmail: const Text("contact.minhajmahim@gmail.com"),
//             currentAccountPicture: CircleAvatar(
//               child: ClipOval(
//                 child: Image.asset(
//                   "assets/images/avator.png",
//                   width: 90,
//                   height: 90,
//                   // fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             decoration: const BoxDecoration(color: colorRed),
//           ),
//           // ListTile(
//           //   leading: const Icon(Icons.favorite),
//           //   title: const Text("Favorite"),
//           //   onTap: () {},
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.people),
//           //   title: const Text("Friends"),
//           //   onTap: () {},
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.share),
//           //   title: const Text("Share"),
//           //   onTap: () {},
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.notifications),
//           //   title: const Text("Request"),
//           //   trailing: ClipOval(
//           //     child: Container(
//           //       color: Colors.red,
//           //       width: 20,
//           //       height: 20,
//           //       child: const Center(
//           //           child: Text(
//           //         "10",
//           //         style: TextStyle(color: Colors.white, fontSize: 12),
//           //       )),
//           //     ),
//           //   ),
//           //   onTap: () {},
//           // ),
//           // const Divider(),
//           // ListTile(
//           //   leading: const Icon(Icons.settings),
//           //   title: const Text("Settings"),
//           //   onTap: () {
//           //
//           //   },
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.file_copy),
//           //   title: const Text("Policies"),
//           //   onTap: () {},
//           // ),
//           // const Divider(),
//           // ListTile(
//           //   leading: const Icon(Icons.exit_to_app),
//           //   title: const Text("Log Out"),
//           //   onTap: () {
//           //     Navigator.pushReplacement(context,
//           //         MaterialPageRoute(builder: (context) => LoginScreen()));
//           //   },
//           // ),
//         ],
//       ),
//     );
//   }
// }
