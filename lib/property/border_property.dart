import 'package:flutter/material.dart';

/// 边框的参数属性值
class BorderProperty {
  const BorderProperty({
    required this.color,
    required this.borderThickness,
  });

  /// 只设置边框的厚度，颜色取默认值
  const BorderProperty.onlyThickness(this.borderThickness) : color = const BorderColor.def();

  /// 边框颜色
  final BorderColor color;

  /// 边框厚度，也用作内容的内边距以免被遮挡
  final double borderThickness;
}

class BorderColor {
  final Color leftColor;
  final Color topColor;
  final Color rightColor;
  final Color bottomColor;

  static const Color defaultColor = Color(0xFF595959);

  const BorderColor.def()
      : leftColor = defaultColor,
        topColor = defaultColor,
        rightColor = defaultColor,
        bottomColor = defaultColor;

  const BorderColor.none()
      : leftColor = Colors.transparent,
        topColor = Colors.transparent,
        rightColor = Colors.transparent,
        bottomColor = Colors.transparent;

  const BorderColor.all(Color color)
      : leftColor = color,
        topColor = color,
        rightColor = color,
        bottomColor = color;
}
