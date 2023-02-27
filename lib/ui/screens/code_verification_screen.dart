
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:tuie_driver/constants/constant_color.dart';
import 'package:tuie_driver/ui/screens/home_screen.dart';
import 'package:tuie_driver/ui/screens/insert_number_screen.dart';
import 'package:tuie_driver/ui/screens/register_login_screen.dart';


class CodeVerificationScreen extends StatefulWidget {
  CodeVerificationScreen({
    Key? key,
  }) : super(key: key);


  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {

  //****************************************************
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  bool? _isInternetAvailableOnCall;
  bool _isInternetAvailableStreamStatus = false;

  StreamSubscription<bool>? _networkConnectionStream;

  final FlutterNetworkConnectivity _flutterNetworkConnectivity =
  FlutterNetworkConnectivity(
    isContinousLookUp: true,
    // optional, false if you cont want continous lookup.
    lookUpDuration: const Duration(seconds: 5),
    // optional, to override default lookup duration.
    // lookUpUrl: 'example.com', // optional, to override default lookup url
  );

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    _flutterNetworkConnectivity.getInternetAvailabilityStream().listen((event) {
      _isInternetAvailableStreamStatus = event;
      setState(() {});
    });
    init();
    super.initState();
  }



  @override
  void dispose() {
    errorController!.close();
    _networkConnectionStream?.cancel();
    _flutterNetworkConnectivity.unregisterAvailabilityListener();
    super.dispose();
  }

  void init() async {
    await _flutterNetworkConnectivity.registerAvailabilityListener();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
  }


  //**************** WIDGET ROOT ************* */
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [

            //--------------- APPBAR --------------- -/
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                //::::::::::::::: ARROW BACK ::::::::::: :/
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const InsertNumberScreen(),
                        //ProductPage
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.08, top: MediaQuery.of(context).size.height * 0.04),
                    height: MediaQuery.of(context).size.height / 16,
                    width: MediaQuery.of(context).size.width / 9,
                    decoration: BoxDecoration(
                      color: ConstantColor.transparentColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                //----------------- SPACE ------------------- -/
                const SizedBox(width: 80,),

                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Text(
                    'Introduzir o código',
                    style: GoogleFonts.quicksand(
                        color: ConstantColor.blackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
              ],
            ),



            //----------------- SPACE ------------------- -/
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            //--------- DESRIPTION INPUT ---------- -/
            Container(
              width: MediaQuery.of(context).size.width / 1.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enviamos um código para',
                    style: GoogleFonts.quicksand(
                        color: ConstantColor.colorClickButton,
                        fontSize: 15,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                  Text(
                    '+244 948824600',
                    style: GoogleFonts.quicksand(
                        color: ConstantColor.blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  Text(
                    'Editar o número de telefone',
                    style: GoogleFonts.quicksand(
                        color: ConstantColor.colorPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),

            //----------------- SPACE ------------------- -/
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            //----------- INPUTS CODE ------------- -/
            GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height / 7,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  children: <Widget>[
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 4,
                          obscureText: true,
                          //backgroundColor: Colors.black38,
                          obscuringCharacter: '*',
                          obscuringWidget: Icon(Icons.check, color: ConstantColor.colorPrimary,),
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v!.length < 3) {
                              return "Código incompleto ou errado, verifique!";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                            selectedFillColor: Colors.black12,
                            disabledColor: Colors.black12,
                            selectedColor: ConstantColor.colorPrimary,
                            inactiveColor: Colors.black12,
                            inactiveFillColor: Colors.black12,
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 60,
                            fieldWidth: 60,
                            activeFillColor: ConstantColor.colorClickButton,
                          ),
                          cursorColor: ConstantColor.colorClickButton,
                          animationDuration: Duration(milliseconds: 300),
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,

                          onCompleted: (v) {
                          },
                          // onTap: () {
                          //   print("Pressed");
                          // },
                          onChanged: (value) {
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //----------------- SPACE ------------------- -/
            const SizedBox(height: 10,),

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

            //----------- BUTTON CHECK & RESEND ----------- -/
            _buttonCheckResend(),

          ],
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
                  return ConstantColor.colorPrimary.withOpacity(0.5);
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
                  builder: (BuildContext context) => const HomeScreen(),
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
