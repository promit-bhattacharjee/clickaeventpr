import 'package:clickaeventpr/screen/onborading/login_screen.dart';
import 'package:clickaeventpr/screen/onborading/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/images/balloonebackground.svg',
            fit: BoxFit.cover,
            width: 412,
            height: 900,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      const SizedBox(height: 275),
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: 300,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    // const SizedBox(height: 100),
                    Container(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const RegistrationScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red,
                              // fontFamily: 'Montserrat',
                              style: BorderStyle.solid,
                              width: 2.0,
                            ),
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red,
                              style: BorderStyle.solid,
                              width: 2.0,
                            ),
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "Log In",
                                  style: TextStyle(
                                    color: Colors.red,
                                    // fontFamily: 'Montserrat',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
