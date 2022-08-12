import 'package:flutter/material.dart';
import 'package:flutter_window/border/windows_border_box.dart';
import 'package:flutter_window/property/border_property.dart';
import 'package:flutter_window/windows_state.dart';

class Windows extends StatefulWidget {
  const Windows({
    Key? key,
    required this.index,
    required this.body,
    this.title = "Flutter Toolman Windows",
    this.height = 350,
    this.width = 350,
    this.draggable = true,
    this.isFullscreen = false,
    this.header,
    this.border = const BorderProperty(
      color: BorderColor.def(),
      borderThickness: 1,
    ),
    this.position = const Offset(0, 0),
  }) : super(key: key);

  final String? title;

  final double? height;

  final double? width;

  /// 自定义头部组件，不存在则默认
  final Widget? header;

  final Widget body;

  /// 是否可拖动，悬浮状态可以拖动
  final bool? draggable;

  /// 是否全屏
  final bool? isFullscreen;

  /// 窗口位置
  final Offset? position;

  /// 边框属性
  final BorderProperty? border;

  /// 层级，数字越大则在最顶层
  final int index;

  @override
  State<Windows> createState() => _WindowsState();
}

class _WindowsState extends State<Windows> with SingleTickerProviderStateMixin {
  final GlobalKey windowsKey = GlobalKey();
  late final WindowsState _oldState = WindowsState();
  late Offset _position;
  final double _minHeight = 350;
  final double _minWidth = 350;

  final double _headerHeight = 35;

  late bool _isFullscreen;

  late double _windowsHeight;
  late double _windowsWidth;

  /// 边框厚度
  late double _borderThickness;
  final Color _borderColor = const Color(0xFF595959);

  @override
  void initState() {
    super.initState();

    _borderThickness = widget.border!.borderThickness;
    _isFullscreen = widget.isFullscreen!;
    _windowsHeight = widget.height! < _minWidth ? _minWidth : widget.height!;
    _windowsWidth = widget.width! < _minWidth ? _minWidth : widget.width!;
    _position = widget.position!;

    _setOldState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkCritical();
    _setOldState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildWindows(context);
  }

  /// 检查临界值，位置和宽高是否超出窗口
  /// 超出则挪到可视位置
  void _checkCritical() {
    Size controllerSize = MediaQuery.of(context).size;
    var criticalPointX = _position.dx + _windowsWidth;
    var criticalPointY = _position.dy + _windowsHeight;
    var newDx = _position.dx;
    var newDy = _position.dy;
    if (criticalPointX > controllerSize.width) {
      newDx = criticalPointX - controllerSize.width;
    }
    if (criticalPointY > controllerSize.height) {
      newDy = criticalPointY - controllerSize.height;
    }
    _position = Offset(newDx, newDy);
  }

  /// 保存窗口前一次变化的属性
  void _setOldState() {
    _oldState
      ..windowsHeight = _windowsHeight
      ..windowsWidth = _windowsWidth
      ..dy = _position.dy
      ..dx = _position.dx;
  }

  Widget _buildWindows(BuildContext context) {
    Size controllerSize = MediaQuery.of(context).size;
    return Positioned(
      key: windowsKey,
      left: _position.dx,
      top: _position.dy,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: controllerSize.height,
          maxWidth: controllerSize.width,
          minHeight: _minHeight,
          minWidth: _minWidth,
        ),
        child: SizedBox(
          height: _windowsHeight,
          width: _windowsWidth,
          child: Stack(
            children: [
              WindowsBorderBox(
                parentKey: windowsKey,
                windowsHeight: _windowsHeight,
                windowsWidth: _windowsWidth,
                minHeight: _minHeight,
                minWidth: _minWidth,
                borderProperty: widget.border!,
                overlayState: Overlay.of(
                  context,
                  debugRequiredFor: widget,
                  rootOverlay: false,
                )!,
                onEnd: (width, height, offset) {
                  _windowsWidth = width;
                  _windowsHeight = height;
                  _position = offset;
                  _setOldState();
                  setState(() {});
                },
              ),
              Padding(
                padding: EdgeInsets.all(_borderThickness),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildBody(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 创建顶部工具栏
  Widget _buildHeader() {
    return Material(
      child: Draggable(
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          if (!widget.draggable!) {
            return;
          }
          _position = offset;
          _setOldState();

          setState(() {});
        },
        feedback: _buildDragFeedback(_windowsHeight, _windowsWidth),
        child: Container(
          width: _windowsWidth - _borderThickness * 2,
          height: _headerHeight,
          color: Colors.transparent,
          alignment: Alignment.centerLeft,
          child: widget.header ??
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: Text("${widget.title}"),
                  ),
                  _buttonFullscreen(),
                ],
              ),
        ),
      ),
    );
  }

  /// 创建显示内容区域
  Widget _buildBody() {
    return Expanded(
      child: Container(
        color: const Color(0xFF434343),
        width: _windowsWidth - _borderThickness * 2,
        height: _windowsHeight - _headerHeight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: widget.body,
        ),
      ),
    );
  }

  Widget _buildDragFeedback(double height, double width) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: height,
        maxWidth: width,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _borderColor.withOpacity(0.3),
          border: Border.all(color: _borderColor, style: BorderStyle.solid),
        ),
      ),
    );
  }

  /// ********************************
  /// 铺满屏幕按钮
  Widget _buttonFullscreen() {
    return IconButton(
      onPressed: () {
        if (_isFullscreen) {
          _windowsWidth = _oldState.windowsWidth;
          _windowsHeight = _oldState.windowsHeight;
          _position = Offset(_oldState.dx, _oldState.dy);
        } else {
          final size = MediaQuery.of(context).size;
          _windowsWidth = size.width;
          _windowsHeight = size.height;
          _position = const Offset(0, 0);
        }

        _isFullscreen = !_isFullscreen;

        setState(() {});
      },
      icon: Icon(
        !_isFullscreen ? Icons.fullscreen : Icons.fullscreen_exit,
        size: 20,
      ),
    );
  }
}
