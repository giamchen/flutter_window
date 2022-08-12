# flutter_window

一个可以拖拽缩放的窗口组件

## 📺  平台

| Android | Windows | Linux | Web |  MacOS | iOS |  
| --- | --- | --- | --- | --- | --- |
| ❌ | ❌ | ❌ | ✔️ | ❌ | ❌ |

> 时间有限，暂时只测试了Web平台

## 📦 安装
在`pubspec.yaml`文件添加依赖:

```yaml
dependencies:
  flutter_window: ^latest_version
```

## 💻 示例

```dart
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
```
> 组件必须用 `Stack` 组件包裹，不然无法拖动，更多属性参考源码。

## ⚙️属性

| 属性值 | 类型 |说明                           |
| ------| ---- |--------------------------------- |
| index | int | 窗口组件索引（预留）|
| header | widget? | 自定义头部，不设置默认包含全屏按钮和标题 |
| body | widget | 窗口主体内容 |
| title | string? | 窗口标题 |
| height | double? | 窗口高度，默认值 350 |
| width | double? | 窗口宽度， 默认值 350 |
| draggable | bool? | 是否可拖动 |
| isFullscreen | bool? | 是否全屏 |
| border | BorderProperty? | 具体属性查看`BorderProperty` |
| position | Offset? | 窗口偏移值 |


## 📢 最后
这算是我的一个Flutter练手代码，刚接触Flutter不久还有很多不熟悉，如果有哪些地方写的不好，还望各位大佬包涵。
也欢迎各路大神指点迷津。

## 开源协议
本项目基于**BSD3**协议