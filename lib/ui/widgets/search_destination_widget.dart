import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuie_driver/constants/constant_color.dart';

class SearchDestinationWidget extends StatelessWidget {
  const SearchDestinationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //elevation: 0,
      color: ConstantColor.whiteColor,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        children: [
          Row(
            children: [
              const BackButton(),
              Text(
                'Onde quer ir?',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.blackColor,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                   // border: ,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ConstantColor.transparentColor,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    fillColor: ConstantColor.colorLigth,
                      prefixIcon: const Icon(
                        Icons.my_location,
                        color: ConstantColor.colorFacebook,
                      ),
                      filled: true,
                      hintText: 'Golf - 2',
                      hintStyle: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.blackColor,
                      ),
                  ),
                ),

                TextField(
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ConstantColor.colorPrimary,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: ConstantColor.blackColor,
                      ),
                      hintText: 'Onde quer ir?',
                    hintStyle: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                ),

                const SizedBox(height: 5,)
              ],
            ),
          ),


        ],
      ),
    );
  }
}
