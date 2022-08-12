import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window/border/windows_border_item.dart';
import 'package:flutter_window/direction.dart';
import 'package:flutter_window/property/border_property.dart';

typedef BorderClickCallback = void Function(Offset offset, Direction direction);
typedef BorderDragCallback = void Function(Offset offset, Direction direction);
typedef BorderEndCallback = void Function(
    double width, double height, Offset offset);

class WindowsBorderBox extends StatefulWidget {
  const WindowsBorderBox({
    Key? key,
    required this.windowsWidth,
    required this.windowsHeight,
    required this.minWidth,
    required this.minHeight,
    required this.parentKey,
    required this.overlayState,
    required this.borderProperty,
    this.onClick,
    this.onDrag,
    this.onEnd,
  }) : super(key: key);

  final GlobalKey parentKey;

  final double windowsWidth;

  final double windowsHeight;

  final double minWidth;

  final double minHeight;

  final OverlayState overlayState;

  final BorderProperty borderProperty;

  final BorderClickCallback? onClick;

  final BorderDragCallback? onDrag;

  final BorderEndCallback? onEnd;

  @override
  State<WindowsBorderBox> createState() => _WindowsBorderBoxState();
}

class _WindowsBorderBoxState extends State<WindowsBorderBox> {
  /// 需要计算的最终偏移值
  late Offset _feedbackOffset;

  /// 点击边框时候，保存当前的光标样式
  late SystemMouseCursor _resizeCursor;

  /// 触发宽高重置的边框线长度
  final double _cornerWidth = 20;

  /// 边框厚度
  late double _borderThickness;

  /// 边框颜色样式
  late BorderColor _borderColor;

  /// 点击边框记录当前坐标，用于计算偏移值
  late Offset _startPosition = Offset.zero;

  /// 限制偏移量，缩小不能少于这个参数值
  late Offset _shrinkLimitOffset;

  OverlayEntry? _entry;

  late double _windowsWidth;

  late double _windowsHeight;

  @override
  void initState() {
    super.initState();

    _windowsWidth = widget.windowsWidth;
    _windowsHeight = widget.windowsHeight;
    _borderColor = widget.borderProperty.color;
    _borderThickness = widget.borderProperty.borderThickness;
    _feedbackOffset = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    return _buildWindowsBorder();
  }

  @override
  void dispose() {
    super.dispose();
    _clearPoint();
  }

  void _onClick(Offset position, Direction direction, cursor) {
    _buildPoint();
    _startPosition = position;
    _resizeCursor = cursor;
    _shrinkLimitOffset = Offset(
      widget.windowsWidth - widget.minWidth,
      widget.windowsHeight - widget.minHeight,
    );
  }

  void _onMoveStart(Offset position, Direction direction) {
    handleBorderMove(position, direction);
  }

  void _onMoveEnd() {
    widget.onEnd!(
      _windowsWidth,
      _windowsHeight,
      _getFinalOffset(_feedbackOffset),
    );
    _clearPoint();
  }

  Widget _buildWindowsBorder() {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: _buildHorizontalBorder(Direction.top),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _buildVerticalBorder(Direction.right),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _buildHorizontalBorder(Direction.bottom),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: _buildVerticalBorder(Direction.left),
          ),
        ],
      ),
    );
  }

  /// 创建水平边框
  Widget _buildHorizontalBorder(Direction direction) {
    return Row(
      children: [
        WindowsBorderItem(
          cursor: Direction.top == direction
              ? SystemMouseCursors.resizeUpLeft
              : SystemMouseCursors.resizeDownLeft,
          height: _borderThickness,
          width: _cornerWidth,
          direction: Direction.top == direction
              ? Direction.topLeft
              : Direction.bottomLeft,
          color: _borderColor.topColor,
          onClick: _onClick,
          onMoveStart: _onMoveStart,
          onMoveEnd: _onMoveEnd,
        ),
        WindowsBorderItem(
          cursor: Direction.top == direction
              ? SystemMouseCursors.resizeUp
              : SystemMouseCursors.resizeDown,
          height: _borderThickness,
          width: widget.windowsWidth - _cornerWidth * 2,
          direction: direction,
          color: _borderColor.topColor,
          onClick: _onClick,
          onMoveStart: _onMoveStart,
          onMoveEnd: _onMoveEnd,
        ),
        WindowsBorderItem(
          cursor: Direction.top == direction
              ? SystemMouseCursors.resizeUpRight
              : SystemMouseCursors.resizeDownRight,
          height: _borderThickness,
          width: _cornerWidth,
          direction: Direction.top == direction
              ? Direction.topRight
              : Direction.bottomRight,
          color: _borderColor.topColor,
          onClick: _onClick,
          onMoveStart: _onMoveStart,
          onMoveEnd: _onMoveEnd,
        ),
      ],
    );
  }

  /// 创建垂直边框
  Widget _buildVerticalBorder(Direction direction) {
    return Column(
      children: [
        WindowsBorderItem(
          cursor: Direction.left == direction
              ? SystemMouseCursors.resizeUpLeft
              : SystemMouseCursors.resizeUpRight,
          height: _cornerWidth,
          width: _borderThickness,
          direction: Direction.left == direction
              ? Direction.leftTop
              : Direction.rightTop,
          color: _borderColor.topColor,
          onClick: _onClick,
          onMoveStart: _onMoveStart,
          onMoveEnd: _onMoveEnd,
        ),
        WindowsBorderItem(
          cursor: Direction.left == direction
              ? SystemMouseCursors.resizeLeft
              : SystemMouseCursors.resizeRight,
          height: widget.windowsHeight - _cornerWidth * 2,
          width: _borderThickness,
          direction: direction,
          color: _borderColor.topColor,
          onClick: _onClick,
          onMoveStart: _onMoveStart,
          onMoveEnd: _onMoveEnd,
        ),
        WindowsBorderItem(
          cursor: Direction.left == direction
              ? SystemMouseCursors.resizeDownLeft
              : SystemMouseCursors.resizeDownRight,
          height: _cornerWidth,
          width: _borderThickness,
          direction: Direction.left == direction
              ? Direction.leftBottom
              : Direction.rightBottom,
          color: _borderColor.topColor,
          onClick: _onClick,
          onMoveStart: _onMoveStart,
          onMoveEnd: _onMoveEnd,
        ),
      ],
    );
  }

  void handleBorderMove(Offset position, Direction direction) {
    switch (direction) {
      case Direction.top:
        _calculate(position, 0, -1, true, false);
        break;
      case Direction.topLeft:
        _calculate(position, -1, -1, false, false);
        break;
      case Direction.topRight:
        _calculate(position, 1, -1, true, false);
        break;
      case Direction.bottom:
        _calculate(position, 0, 1, true, true);
        break;
      case Direction.bottomLeft:
        _calculate(position, -1, 1, false, true);
        break;
      case Direction.bottomRight:
        _calculate(position, 1, 1, true, true);
        break;
      case Direction.left:
        _calculate(position, -1, 0, false, true);
        break;
      case Direction.leftTop:
        _calculate(position, -1, -1, false, false);
        break;
      case Direction.leftBottom:
        _calculate(position, -1, 1, false, true);
        break;
      case Direction.right:
        _calculate(position, 1, 0, true, true);
        break;
      case Direction.rightTop:
        _calculate(position, 1, -1, true, false);
        break;
      case Direction.rightBottom:
        _calculate(position, 1, 1, true, true);
        break;
      default:
        break;
    }
  }

  /// 计算距离和偏移量
  /// factor是XY轴的计算系数，[1,-1,0]
  void _calculate(
      Offset position, int factorX, int factorY, bool fixedX, bool fixedY) {
    double distanceX = 0.0;
    double distanceY = 0.0;

    distanceX = position.dx - _startPosition.dx;
    distanceY = position.dy - _startPosition.dy;

    _feedbackOffset = Offset(
        fixedX ? 0 : min(distanceX, _shrinkLimitOffset.dx) * factorX * -1,
        fixedY ? 0 : min(distanceY, _shrinkLimitOffset.dy) * factorY * -1);

    _windowsHeight =
        max(widget.windowsHeight + distanceY * factorY, widget.minHeight);
    _windowsWidth =
        max(widget.windowsWidth + distanceX * factorX, widget.minWidth);

    _updateParentState();
  }

  Offset _getFinalOffset(Offset position) {
    var controllerSize = MediaQuery.of(context).size;
    var parentLocal = _getParentPosition();

    var finalDx = parentLocal.dx + position.dx;
    var finalDy = parentLocal.dy + position.dy;

    if (finalDx <= 0) {
      finalDx = 0;
    } else if (finalDx + _windowsWidth >= controllerSize.width) {
      finalDx = controllerSize.width - _windowsWidth;
    }

    if (finalDy <= 0) {
      finalDy = 0;
    } else if (finalDy + _windowsHeight >= controllerSize.height) {
      finalDy = controllerSize.height - _windowsHeight;
    }

    return Offset(finalDx, finalDy);
  }

  void _updateParentState() {
    widget.overlayState.setState(() {});
  }

  void _clearPoint() {
    _entry?.remove();
    _entry = null;
    _clearResize();
  }

  void _buildPoint() {
    _clearPoint();
    var parentLocal = _getParentPosition();

    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: parentLocal.dx + _feedbackOffset.dx,
          top: parentLocal.dy + _feedbackOffset.dy,
          child: SizedBox(
            height: _windowsHeight,
            width: _windowsWidth,
            child: MouseRegion(
              cursor: _resizeCursor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),
        );
      },
    );

    widget.overlayState.insert(_entry!);
  }

  void _clearResize() {
    _feedbackOffset = Offset.zero;
    _windowsWidth = widget.windowsWidth;
    _windowsHeight = widget.windowsHeight;
  }

  RenderBox _getParentBox() {
    return widget.parentKey.currentContext?.findRenderObject() as RenderBox;
  }

  Offset _getParentPosition() {
    return _getParentBox().localToGlobal(Offset.zero);
  }
}
