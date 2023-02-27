import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuie_driver/constants/constant_color.dart';
import 'package:tuie_driver/ui/screens/code_verification_screen.dart';
import 'package:tuie_driver/ui/screens/register_login_screen.dart';



class InsertNumberScreen extends StatefulWidget {
  const InsertNumberScreen({Key? key}) : super(key: key);

  @override
  State<InsertNumberScreen> createState() => _InsertNumberScreenState();
}

class _InsertNumberScreenState extends State<InsertNumberScreen> {

  String otpPin = " ";
  String countryDial = "+244";
  String verID = " ";
  int screenState = 0;

  final FlutterNetworkConnectivity _flutterNetworkConnectivity =
  FlutterNetworkConnectivity(
    isContinousLookUp: true,
    // optional, false if you cont want continous lookup.
    lookUpDuration: const Duration(seconds: 5),
    // optional, to override default lookup duration.
    // lookUpUrl: 'example.com', // optional, to override default lookup url
  );

  bool? _isInternetAvailableOnCall;
  bool _isInternetAvailableStreamStatus = false;

  StreamSubscription<bool>? _networkConnectionStream;

  //********************** INITSTATE ********************** */
  @override
  void initState() {
    super.initState();
    _flutterNetworkConnectivity.getInternetAvailabilityStream().listen((event) {
      _isInternetAvailableStreamStatus = event;
      setState(() {});
    });
    init();
  }


  @override
  void dispose() {
    _networkConnectionStream?.cancel();
    _flutterNetworkConnectivity.unregisterAvailabilityListener();
    super.dispose();
  }

  void init() async {
    await _flutterNetworkConnectivity.registerAvailabilityListener();
  }

  void showSnackBarText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  Future<void> verifyPhone(String number) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 20),
      verificationCompleted: (PhoneAuthCredential credential) {
        showSnackBarText("Auth Completed!");
      },
      verificationFailed: (FirebaseAuthException e) {
        showSnackBarText("Auth Failed!");
      },
      codeSent: (String verificationId, int? resendToken) {
        showSnackBarText("OTP Sent!");
        verID = verificationId;
        setState(() {
          screenState = 1;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showSnackBarText("Timeout!");
      },
    );
  }

  Future<void> verifyOTP() async {
    await FirebaseAuth.instance.signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: verID,
        smsCode: otpPin,
      ),
    ).whenComplete(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>  CodeVerificationScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstantColor.whiteColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ConstantColor.whiteColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              InkWell(
                onTap: (){
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const RegisterLoginScreen(),
                      ),
                    );
                  });
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: ConstantColor.blackColor,
                ),
              ),

              //---------------------------- SPACE ---------------------------- -/
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),

              Text(
                'Insere o teu número.',
                style: GoogleFonts.quicksand(
                    color: ConstantColor.blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),

        body: Container(
          child: Column(
            children: [

              //----------------- SPACE ------------------- -/
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),


              Container(
                height: MediaQuery.of(context).size.height / 12,
                width: MediaQuery.of(context).size.width / 1.2,
                decoration: BoxDecoration(
                    color: ConstantColor.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: ConstantColor.colorPrimary, style: BorderStyle.solid)
                ),
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                child: Center(
                  child: TextFormField(
                    maxLines: null,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration.collapsed(
                      border: InputBorder.none,
                      hintText: 'Digite o número',
                      hintStyle: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: ConstantColor.blackColor),
                    ),
                    //focusNode: telefone_passageiro,
                    validator: (value) {
                      setState(() {
                        //telefone_usuario = value;
                      });
                      if (value == null || value.isEmpty) {
                        return 'Por favor digite o telefone correto';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    // controller: _telefone_usuario_controller,
                    // obscureText: true,
                  ),
                ),
              ),

              //----------------- SPACE ------------------- -/
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: Text(
                  'Vamos enviar-te um código SMS para confirmar o seu número.',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: ConstantColor.colorClickButton,
                  ),
                ),
              ),

              _isInternetAvailableStreamStatus
                  ? Text(
                '',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ConstantColor.blackColor,
                ),
              )
                  : Column(
                children: [
                  Icon(
                    Icons.warning,
                    size: 50,
                    color: ConstantColor.colorPrimary,
                  ),
                  Text(
                    'Estas Offline, Conecte-se a internet.',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                ],
              ),

              //---------------------------- SPACE ---------------------------- -/
              isKeyboard ? SizedBox(height: MediaQuery.of(context).size.height * 0.04) : SizedBox(height: MediaQuery.of(context).size.height * 0.50),

              _buttonCheckResend(),
            ],
          ),
        ),
      ),
    );
  }

  //********************* CHECK & RESEND ********************** */
  _buttonCheckResend(){
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height / 12,
        width: MediaQuery.of(context).size.width / 1.2,
        decoration: BoxDecoration(
          color: ConstantColor.colorPrimary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextButton(
          style: ButtonStyle(
            foregroundColor:
            MaterialStateProperty.all<Color>(Colors.blue),
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered))
                  return ConstantColor.colorPrimary.withOpacity(0.04);
                if (states.contains(MaterialState.focused) ||
                    states.contains(MaterialState.pressed))
                  return ConstantColor.whiteColor;
                return null; // Defer to the widget's default.
              },
            ),
          ),
          onPressed: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => CodeVerificationScreen(),
                ),
              );
            });
          },
          child: Center(
            child: Text(
              'Confirmar',
              style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.whiteColor),
            ),
          ),
        ),
      ),
    );
  }
}
