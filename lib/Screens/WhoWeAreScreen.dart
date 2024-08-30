import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class WhoWeAre extends StatefulWidget {
  const WhoWeAre({super.key});

  @override
  State<WhoWeAre> createState() => _WhoWeAreState();
}

class _WhoWeAreState extends State<WhoWeAre> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0),
        elevation: 0,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.black,)),
        title: Text("Who We Are", style: GoogleFonts.lato(
          color: Colors.black
        ),),
      ),
      body: Column(
crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: size.height*0.8,
              width: size.width*0.96,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                    BoxShadow(color: Colors.grey,
                    offset: Offset(0.4, 0.2),
                    blurRadius: 0.2,
                    spreadRadius: 0.4,
                    )
                  ],
              ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: size.width*0.035, top: size.height*0.03, bottom: size.height*0.027),
                    child: Text("What You Need To Know About IPPU", style: GoogleFonts.montserrat(
                      fontSize: size.height*0.023, fontWeight: FontWeight.bold
                    ),),
                  ),
                  const Divider(
                    thickness: 0.2,
                  color: Colors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: size.width*0.021,right: size.width*0.021, top: size.height*0.012),
                    child: Text("The Institute of Procurement Professionals of Uganda (IPPU) is a professional body that was established to bring together both the public and private sector procurement and supply chain professionals in Uganda. The idea to form IPPU was because of the growing concern to have in place an institutional self-regulating framework, which could ensure that procurement professionals and practitioners in Uganda conducted themselves professionally and maintained best procurement practices in carrying out their work.", textAlign: TextAlign.justify,   style: GoogleFonts.lato(
    textStyle: const TextStyle(color: Colors.black), // Set text color to white
  ),),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: size.width*0.021,right: size.width*0.021, top: size.height*0.012),
                    child: Text("Since 2005 there were various meetings and consultations which where spear headed by the Public Procurement and Disposal of Public Assets Authority (PPDA), Ministry of Finance, Planning and Economic Development (MOFPED) and various development partners. this led to the formation of a committee which was given the mandate to promote a local professional body after a series of these consultations with various stakeholders, IPPU was incorporated as a company limited by guarantee on the 4th April 2008, together with the election of an interim council in May 2008. The interim council was to be the governing body of the institute. The organization’s main objective is to prescribe, regulate the practice and conduct of members of the procurement profession and to promote procurement professional standards in Uganda.", textAlign: TextAlign.justify,   style: GoogleFonts.lato(
    textStyle: const TextStyle(color: Colors.black), // Set text color to white
  ),),
                  ),
                ],
              ),
            )),
          )
        ],
      ),
    );
  }
}