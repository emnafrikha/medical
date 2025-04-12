import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Config {
  static MediaQueryData? mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  /// Initialize screen dimensions
  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  /// Safe getters with fallback values
  static double get widthSize {
    return screenWidth != 0 ? screenWidth : 360.0; // Default width if uninitialized
  }

  static double get heightSize {
    return screenHeight != 0 ? screenHeight : 640.0; // Default height if uninitialized
  }

  /// Dynamic spacing widgets
  static const spaceSmall = SizedBox(height: 25);
  static SizedBox get spaceMedium => SizedBox(height: screenHeight * 0.05);
  static SizedBox get spaceBig => SizedBox(height: screenHeight * 0.08);
  static SizedBox get ultraBig => SizedBox(height: screenHeight * 0.1);

  /// Input Borders
  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.green,
      ));

  static const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.red,
      ));

  /// Colors
  static const Color primaryColor = Color(0xFFFDEA1D);
  static const Color secondaryColor = Color(0xFF646464);
  static const Color buttonTextColor = Color(0xFF1E1E1E);
  static const Color inputBorderColor = Color(0xFF969696);

  /// Email Validation RegEx
  static final RegExp emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
    multiLine: false,
  );
}

/// Example usage in a widget
class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    // Initialize Config to set screen dimensions
    Config().init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Config Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Config.spaceSmall,
            Text("Screen Width: ${Config.widthSize.toStringAsFixed(2)}"),
            Text("Screen Height: ${Config.heightSize.toStringAsFixed(2)}"),
            Config.spaceMedium,
            Container(
              width: Config.widthSize * 0.8,
              height: Config.heightSize * 0.1,
              decoration: BoxDecoration(
                color: Config.primaryColor,
                border: Border.all(color: Config.inputBorderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Primary Color Box",
                  style: TextStyle(color: Config.buttonTextColor),
                ),
              ),
            ),
            Config.spaceBig,
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Email",
                border: Config.outlinedBorder,
                focusedBorder: Config.focusBorder,
                errorBorder: Config.errorBorder,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter an email";
                } else if (!Config.emailRegExp.hasMatch(value)) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
