import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tuie_driver/constants/constant_color.dart';
import 'package:tuie_driver/ui/screens/initial_screen.dart';
import 'package:tuie_driver/ui/screens/register_login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: ConstantColor.blackColor,
        backgroundColor: ConstantColor.whiteColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perfil',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ConstantColor.blackColor,
              ),
            ),

            const Icon(
              Icons.edit,
              color: ConstantColor.blackColor,
              size: 30,
            )
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    maxRadius: 30,
                    minRadius: 20,
                    backgroundImage: AssetImage(
                        "assets/logo/logo_tuie.png"),
                  ),


                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text(
                        "Tuie Comigo",
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ConstantColor.blackColor,
                        ),
                      ),

                      Text(
                        "+244923111222",
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ConstantColor.colorClickButton,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 30,
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [

                          const Icon(
                            Icons.email,
                            color: ConstantColor.colorClickButton,
                          ),

                          SizedBox(
                            width: 10,
                          ),


                          Text(
                            "tuiecomigo@gmail.com",
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ConstantColor.blackColor,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: ConstantColor.colorPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Verificar",
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ConstantColor.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),

          Divider(
            height: 50,
            thickness: 10,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Locais Favoritos",
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ConstantColor.blackColor,
              ),
            ),
          ),

          SizedBox(
            height: 20,
          ),

          ListTile(
            leading: const Icon(Icons.home_filled),
            title: Text(
              "Insere a morada de casa",
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ConstantColor.blackColor,
              ),

            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: Text(
              "Insere a morada de trabalho",
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ConstantColor.blackColor,
              ),
            ),
            onTap: () {},
          ),

          Divider(
            height: 50,
            thickness: 10,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Idioma",
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ConstantColor.blackColor,
                  ),
                ),

                Text(
                  "Portugues",
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ConstantColor.colorClickButton,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 30,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Preferências de comunicação",
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ConstantColor.blackColor,
              ),
            ),
          ),

          Divider(
            height: 50,
            thickness: 10,
          ),


          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: Text(
              "Sair",
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ConstantColor.blackColor,
              ),
            ),
            onTap: () => _alertDialog(context),
          ),

        ],
      ),
    );
  }

  _alertDialog(BuildContext context) {
    var alertStyle = AlertStyle(
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),

        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: ConstantColor.colorPrimary,
      ),
    );
    Platform.isIOS ?  CupertinoAlertDialog(
      title: Text(
        "Alerta",
        style: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ConstantColor.colorPrimary,
        ),
      ),
      content: Text(
        "De certeza que quer sair?",
        style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: ConstantColor.colorPrimary,
        ),
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => RegisterLoginScreen(),
                //ProductPage
              ),
            );
          },
          child: const Text('Ok'),
        ),

        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    )

        :

    Platform.isAndroid ? Alert(
      context: context,
      style: alertStyle,
      type: AlertType.warning,
      title: "Alerta",
      desc: "De certeza que quer sair?",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ConstantColor.colorFacebook,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => InitialScreen(),
                //ProductPage
              ),
            );

          },
          color: ConstantColor.whiteColor,
        ),
        DialogButton(
          splashColor: ConstantColor.whiteColor,
          highlightColor: ConstantColor.whiteColor,
          onPressed: () {
            Navigator.pop(context);
          },
          color: ConstantColor.colorFacebook,
          child: Text(
            "Cancelar",
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ConstantColor.whiteColor,
              ),
          ),
        )
      ],
    ).show() : Container();
  }
}
