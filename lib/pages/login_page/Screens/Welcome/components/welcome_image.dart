import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Journey Of Your Books\n",
                style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: Colors.black),
                children: const <TextSpan>[
                  TextSpan(
                      text: 'with',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' Book+ !'),
                ],
              )),
          const SizedBox(height: defaultPadding),
          Row(
            children: [
              const Spacer(),
              Expanded(
                  flex: 8,
                  child: Image.asset('assets/images/welcome_world.png')),
              const Spacer(),
            ],
          ),
          const SizedBox(height: defaultPadding * 2),
        ],
      ),
    );
  }
}
