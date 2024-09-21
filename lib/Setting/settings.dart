
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../screen/main manu/home.dart';
import '../style/style.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar:AppBar(
       backgroundColor: colorRed,
       elevation: 1,
       leading: IconButton(
         onPressed: (){
           Navigator.of(context).push(MaterialPageRoute(builder:
           (BuildContext context)=>const Home()));
         },
         icon: const Icon(Icons.arrow_back),
       ),
     ) ,
      body: Container(
        padding: const EdgeInsets.only(left: 16,top: 25,right: 16),
        child: ListView(
          children: const [
            Text("Settings",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w500,color: Colors.black)),
            SizedBox(height: 40,),
            Row(
              children: [
                Icon(Icons.person,color: Colors.red,),
                SizedBox(width: 8,),
                Text("Account",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),)
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Change Password",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,)
                  ],
                ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Content settings",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,)
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Social",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,)
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Language",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,)
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Privacy and security",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,),

                ],
              ),
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                Icon(Icons.volume_up_outlined,color: Colors.red,),
                SizedBox(width: 8,),
                Text("Notification",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),)
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("New for you",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,)
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Account activity",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,)
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Opportunity",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,),

                ],

              ),

            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Opportunity",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
                  Icon(Icons.arrow_forward_ios,color:Colors.grey ,),

                ],

              ),

            ),

          ]
        ),
      ),

    );
  }
}
