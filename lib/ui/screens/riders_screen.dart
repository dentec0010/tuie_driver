import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuie_driver/constants/constant_color.dart';


class RidersScreen extends StatefulWidget {
  const RidersScreen({Key? key}) : super(key: key);

  @override
  State<RidersScreen> createState() => _RidersScreenState();
}

class _RidersScreenState extends State<RidersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: ConstantColor.blackColor,
        backgroundColor: ConstantColor.whiteColor,
        elevation: 0,
        title: Text(
          'Viagens',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ConstantColor.blackColor,
          ),
        )
      ),

      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 12,
        padding: EdgeInsets.only(left: 10),
        itemBuilder: (context, index){
          return Container(
            height: MediaQuery.of(context).size.height * 0.1,
            margin: EdgeInsets.only(top: 5, left: 5, right: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ConstantColor.colorLigth,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rotunda do Camama',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.blackColor,
                      ),
                    ),


                    Text(
                      'Kilamba, Bloco C',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.blackColor,
                      ),
                    ),

                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [

                        Text(
                          '1600 AOA',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ConstantColor.blackColor,
                          ),
                        ),
                      ],
                    ),


                    Text(
                      '01/02/2023 - 12:43:56',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.blackColor,
                      ),
                    ),

                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
