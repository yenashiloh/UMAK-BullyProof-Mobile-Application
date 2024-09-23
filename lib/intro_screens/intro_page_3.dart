import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 75),
            child: Center(
              child: Image.asset(
                'assets/ob_logo.png',
                width: 130,
              ),
            ),
          ),
          const Text(
            'BullyProof',
            style: TextStyle(
              color: Color.fromRGBO(19, 56, 98, 1),
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/ob3.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}