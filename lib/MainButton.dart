import 'package:flutter/material.dart';

// ButtonTheme mainScreenButton(buttonWidth, text, onPressed) {
//   return ButtonTheme(
//       minWidth: buttonWidth,
//       height: 35.0,
//       child:
//   );
// }

class MainButton extends ButtonTheme {
  MainButton({required buttonWidth, required text, required onPressed})
      : super(
            minWidth: buttonWidth,
            height: 35.0,
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(
                        color: Color.fromRGBO(0, 160, 227, 1))),
                // padding: const EdgeInsets.symmetric(horizontal: 0),
                color: Colors.white,
                textColor: const Color.fromRGBO(0, 160, 227, 1),
                onPressed: onPressed,
                child: Text(text)));
}
