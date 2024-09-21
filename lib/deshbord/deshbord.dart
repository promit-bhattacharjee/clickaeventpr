import 'package:clickaeventpr/screen/main%20manu/PreviousEventsPage.dart';
import 'package:clickaeventpr/screen/main%20manu/ViewReceiptsPage.dart';
import 'package:clickaeventpr/screen/main%20manu/guestListPage.dart';
import 'package:flutter/material.dart';

import '../navbar.dart';
import '../screen/main manu/budget.dart';
import '../screen/main manu/calander.dart';
import '../screen/main manu/checkList.dart';
import '../screen/main manu/event.dart';
import '../screen/main manu/guestsPage.dart';
import '../screen/main manu/searchBar.dart';
import '../screen/main manu/ReceiptPicturePage.dart';
import '../screen/widgets/bodyBackground.dart';
import '../style/style.dart';

class Deshbord extends StatefulWidget {
  const Deshbord({super.key});

  @override
  State<Deshbord> createState() => _DeshbordState();
}

class _DeshbordState extends State<Deshbord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer:  Navbar(),
      appBar: AppBar(
        backgroundColor: colorRed,
        centerTitle: true,
        title: const Text(
          "clickAEvent",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: Search());
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: BodyBackground(
        child: GridView(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 150,
          ),
          children: [
            // InkWell(
            //   onTap: () {
            //     Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            //       return const Calendar();
            //     }));
            //   },
            //   child: Container(
            //     decoration: const BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.all(
            //           Radius.circular(10),
            //         ),
            //         boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
            //     child: Padding(
            //       padding: const EdgeInsets.all(8),
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           Image.asset(
            //             "assets/images/calander.png",
            //             width: 50,
            //             height: 50,
            //           ),
            //           const Text(
            //             "Calendar",
            //             style: TextStyle(
            //                 fontSize: 20, fontWeight: FontWeight.w600),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return const CheckList();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/checklist.png",
                        width: 50,
                        height: 50,
                      ),
                      const Text(
                        "Checklist",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return BudgetPage();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/budget.png",
                        width: 60,
                        height: 60,
                      ),
                      const Text(
                        "Budget",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return ReceiptPicturePage();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/budget_tracker.png",
                        width: 60,
                        height: 60,
                      ),
                      const Text(
                        "Budget Tracker",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return EventApp();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/event.png",
                        width: 60,
                        height: 60,
                      ),
                      const Text(
                        "Event",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return ViewReceiptsPage();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/reception.jpg",
                        width: 60,
                        height: 60,
                      ),
                      const Text(
                        "reception",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return const PreviousEventsPage();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/previous_events.png",
                        width: 50,
                        height: 50,
                      ),
                      const Text(
                        "previous events",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return GuestListPage();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/Guest.png",
                        width: 50,
                        height: 50,
                      ),
                      const Text(
                        "Guests",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return const Guests();
                }));
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/guests.png",
                        width: 50,
                        height: 50,
                      ),
                      const Text(
                        "Add Guest",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
