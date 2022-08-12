import 'package:flutter/material.dart';

/// 用于存放窗口状态
class WindowsState {
  WindowsState({
    this.windowsHeight = 200,
    this.windowsWidth = 200,
    this.dx = 0.0,
    this.dy = 0.0,
    this.index = 0,
  });

  /// 窗口高
  late double windowsHeight;

  /// 窗口宽
  late double windowsWidth;

  /// 窗口位置
  late double dx;
  late double dy;

  late int index;

  late Key key = UniqueKey();
}
