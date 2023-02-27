import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tuie_driver/constants/constant_color.dart';
import 'package:tuie_driver/ui/screens/register_login_screen.dart';


class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {

  @override
  void initState() {
   super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    Future.delayed(const Duration(seconds: 6)).then((_) async {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => RegisterLoginScreen(),
              //RegisterLoginScreen()
          ));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.colorPrimary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          //--------------- IMAGE LOGO ---------------- -/
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                image: const DecorationImage(
                    image: AssetImage("assets/logo/logo_tuie.png"),
                    fit: BoxFit.fill
                ),
              ),
            ),
          ),

          Text(
            'Tuié comigo',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ConstantColor.whiteColor,
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          LoadingAnimationWidget.discreteCircle(
            color: ConstantColor.whiteColor,
            size: 30,
          ),
        ],
      ),
    );
  }
}
