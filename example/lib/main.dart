import 'package:flutter/material.dart';
import 'package:flutter_window/property/border_property.dart';
import 'package:flutter_window/windows.dart';

void main() {
  runApp(const ToolmanApplication());
}

class ToolmanApplication extends StatefulWidget {
  const ToolmanApplication({Key? key}) : super(key: key);

  @override
  State<ToolmanApplication> createState() => _ToolmanApplicationState();
}

class _ToolmanApplicationState extends State<ToolmanApplication> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
      ),
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              // color: Colors.black,
              child: Stack(
                children: const [
                  Windows(
                    draggable: false,
                    border: BorderProperty.onlyThickness(3),
                    height: 500,
                    width: 500,
                    body: Text('Emulates the operating system window,'
                        ' which can be zoomed and dragged'),
                    index: 1,
                    position: Offset(50, 50),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
