
import 'package:clickaeventpr/screen/onborading/login_screen.dart';
import 'package:clickaeventpr/style/style.dart';
import 'package:flutter/material.dart';


class Navbar extends StatelessWidget{
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              accountName: Text("Jakir Hossen"), accountEmail: Text("Jhbjakir@gmail.com"),

          currentAccountPicture: CircleAvatar(
            child: ClipOval(
              child: Image.asset("assets/images/avator.png",
                width:90 ,
                height:90 ,
                // fit: BoxFit.cover,
              ),
            ),
          ) ,
            decoration: BoxDecoration(
                color:colorRed
            ),

           ),
          ListTile(
            leading:Icon(Icons.favorite) ,
            title:Text("Favorite") ,
            onTap: (){} ,
          ), ListTile(
            leading:Icon(Icons.people) ,
            title:Text("Friends") ,
            onTap: (){} ,
          ), ListTile(
            leading:Icon(Icons.share) ,
            title:Text("Share") ,
            onTap: (){} ,
          ), ListTile(
            leading:Icon(Icons.notifications) ,
            title:Text("Request") ,
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: Center(child: Text("10",style: TextStyle(color: Colors.white,fontSize: 12),)),
              ),
            ),
            onTap: (){} ,
          ),
          Divider(),
          ListTile(
            leading:Icon(Icons.settings) ,
            title:Text("Settings") ,
            onTap: (){} ,
          ), ListTile(
            leading:Icon(Icons.file_copy) ,
            title:Text("Policies") ,
            onTap: (){} ,
          ),
          Divider(),
          ListTile(
            leading:Icon(Icons.exit_to_app) ,
            title:Text("Log Out") ,
            onTap: (){
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) =>LoginScreen()));
            } ,
          ),

        ],
      ),
    );
  }

}