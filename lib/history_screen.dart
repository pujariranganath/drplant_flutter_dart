import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // Ensure icons are black
        centerTitle: true,
        elevation: 0, // Remove shadow
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'History Screen\nTo be implemented in the future',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black, // Lighter text color
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
