import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window/direction.dart';

typedef BorderItemClickCallback = void Function(
    Offset position, Direction direction, SystemMouseCursor cursor);

typedef BorderItemMoveStartCallback = void Function(
    Offset position, Direction direction);

typedef BorderItemMoveEndOverCallback = void Function();

class WindowsBorderItem extends StatefulWidget {
  const WindowsBorderItem({
    Key? key,
    required this.direction,
    required this.width,
    required this.height,
    this.onClick,
    this.onMoveStart,
    this.onMoveEnd,
    this.cursor = SystemMouseCursors.click,
    this.color = const Color(0xFF595959),
  }) : super(key: key);

  final Direction direction;

  final double width;

  final double height;

  final BorderItemClickCallback? onClick;

  final BorderItemMoveStartCallback? onMoveStart;

  final BorderItemMoveEndOverCallback? onMoveEnd;

  final SystemMouseCursor cursor;

  final Color color;

  @override
  State<WindowsBorderItem> createState() => _WindowsBorderItemState();
}

class _WindowsBorderItemState extends State<WindowsBorderItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      child: GestureDetector(
        onPanDown: (event) {
          widget.onClick!(event.globalPosition, widget.direction, widget.cursor);
        },
        onPanUpdate: (event) {
          widget.onMoveStart!(event.globalPosition, widget.direction);
        },
        onPanCancel: () {
          widget.onMoveEnd!();
        },
        onPanEnd: (event) {
          widget.onMoveEnd!();
        },
        child: Container(
            color: widget.color, width: widget.width, height: widget.height),
      ),
    );
  }
}
