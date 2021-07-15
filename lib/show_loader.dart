import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

showLoader(context) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
    ),
  );
}

showOfflineAlert(context) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Internet not available",
    desc: "Your device is not connected to Internet. Please try again later.",
    buttons: [
      DialogButton(
        child: Text(
          "Okay",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () async {
          Navigator.pop(context);
        },
        color: Color.fromRGBO(0, 179, 134, 1.0),
      ),
    ],
  ).show();
}
