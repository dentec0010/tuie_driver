import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tuie_driver/constants/constant_color.dart';
import 'package:tuie_driver/ui/screens/code_verification_screen.dart';
import 'package:tuie_driver/ui/screens/insert_number_screen.dart';


class RegisterLoginScreen extends StatefulWidget {
  const RegisterLoginScreen({Key? key}) : super(key: key);

  @override
  State<RegisterLoginScreen> createState() => _RegisterLoginScreenState();
}

class _RegisterLoginScreenState extends State<RegisterLoginScreen> {

  final GoogleSignIn _googleSignIn= GoogleSignIn();
  String username = '';

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




  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    /// Show a simple "___ Button Pressed" indicator
    void _showButtonPressDialog(BuildContext context, String provider) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('$provider Button Pressed!'),
        backgroundColor: Colors.black26,
        duration: Duration(milliseconds: 400),
      ));
    }

    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(height: MediaQuery.of(context).size.height * 0.1,),

            Text(
              'Insere o teu número',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ConstantColor.blackColor,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),


            Container(
              height: MediaQuery.of(context).size.height / 12,
              width: MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                color: ConstantColor.colorLigth.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
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
                  onTap: (){
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const InsertNumberScreen()
                          //
                          //ProductPage
                        ),
                      );
                    });
                  },
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

            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),

            //------------ BUTTON SEND ---------------- -/
            Container(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const InsertNumberScreen()
                         //
                      //ProductPage
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    'Iniciar sessão',
                    style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.whiteColor),
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.04,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 1,
                  color: ConstantColor.colorClickButton,
                ),

                Text('OU'),

                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 1,
                  color: ConstantColor.colorClickButton,
                ),
              ],
            ),


            SizedBox(height: MediaQuery.of(context).size.height * 0.04,),


            Container(
              height: MediaQuery.of(context).size.height / 12,
              width: MediaQuery.of(context).size.width / 1.2,
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
              decoration: BoxDecoration(
                  color: ConstantColor.whiteColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 1, color: ConstantColor.colorClickButton, style: BorderStyle.solid)
              ),
              child: SignInButton(
                text: 'Entrar com o Google',
                Buttons.Google,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: () {
                  _googleSignIn.signIn().then((value){
                    username = value!.displayName!;
                  });
                  _showButtonPressDialog(context, 'Google');
                },
              ),
            ),


            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),


            Container(
              height: MediaQuery.of(context).size.height / 12,
              width: MediaQuery.of(context).size.width / 1.2,
              //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
              decoration: BoxDecoration(
                  color: ConstantColor.colorFacebook,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 1, color: ConstantColor.colorClickButton, style: BorderStyle.solid)
              ),
              child: SignInButton(
                text: 'Entrar com o Facebook',
                Buttons.FacebookNew,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: () {
                  _showButtonPressDialog(context, 'FacebookNew');
                },
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

            SizedBox(height: MediaQuery.of(context).size.height * 0.2),

            Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.colorClickButton,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Se estás a criar uma nova conta, aplicam-se os ',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ConstantColor.colorClickButton,
                        ),
                      ),

                      TextSpan(
                        text: 'Termos & Condições',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ConstantColor.colorClickButton,
                          decoration: TextDecoration.underline
                        ),
                      ),

                      TextSpan(
                        text: ' e a ',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ConstantColor.colorClickButton,
                        ),
                      ),

                      TextSpan(
                        text: 'politica de Privacidade',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ConstantColor.colorClickButton,
                            decoration: TextDecoration.underline
                        ),
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
