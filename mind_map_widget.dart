import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'mindMapPainter.dart';
import 'node.dart';

class MindMapWidget extends StatefulWidget {
  @override
  State<MindMapWidget> createState() => _MindMapWidgetState();
}

class _MindMapWidgetState extends State<MindMapWidget> {
  late FocusNode _node;

  bool _focused = false;

  final _controller = TextEditingController();

  final _textStyle = TextStyle(fontSize: 20, color: Colors.black);
  Node tree = Node("Задача");
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 650);

    _node = FocusNode(debugLabel: "begin");
    _node.addListener(_handleFocusChange);

    // TODO: implement initState
    super.initState();
  }

  void _handleFocusChange() {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _node.removeListener(_handleFocusChange);
    _node.dispose();
    _node.unfocus();

    ///
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        toolbarHeight: 30,
        // foregroundColor: Colors.black,
        title: Text("Mind Maps"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.access_alarms),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                // height: 2000,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  child: Container(
                    width: 1000,
                    height: 2000,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: handleOnTapUp,
                      onDoubleTapDown: handleOnDoubleTapDown,
                      onDoubleTap: () {
                        handleOnTapUp;
                      },
                      onLongPressEnd: handleLongPressEnd,
                      child: CustomPaint(
                        child: Container(),
                        painter: MindMapPainter(tree, canvasStart, scale),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
            Center(
              child: SizedBox(
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleEditMode(String s) {
    if (_focused) {
      _node.unfocus();
    } else {
      _controller.text = s;
      _node.requestFocus();
      setState(() {
        _focused = !_focused;
      });
    }
  }

  void handleOnDoubleTapDown(TapDownDetails details) {
    _selectedNode = depthFirstSearch(tree, (Node m) {
      final inside = m.rect.contains(details.localPosition);
      return inside;
    })!;
    if (_selectedNode != null) {
      toggleEditMode(_selectedNode.value);
    }
  }

  void handleOnTapUp(TapUpDetails details) {
    //  print();

    final n = depthFirstSearch(tree, (Node m) {
      final inside = m.rect.contains(details.localPosition);
      return inside;
    });

    if (n != null) {
      print("Добавлен новый элемент ${n.value}");

      setState(() {
        n.children.add(Node("new node"));
      });
    } else {
      print("Не добалялись новые ноды");
    }
  }

  _buildTextField() {
    if (_focused) {
      return TextField(
        controller: _controller,
        onSubmitted: handleTextFieldInput,
        focusNode: _node,
        style: _textStyle,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.only(left: 10, bottom: 8, top: 8),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  late Node _selectedNode;
  Offset canvasStart = Offset(0, 0);
  double scale = 1.0;
  late double prevScale;

  void handleTextFieldInput(String value) {
    if (_selectedNode != null) {
      _selectedNode.value = value.trim();
      //   toggleEditMode(_selectedNode.value);
      _selectedNode == null;
    }
    toggleEditMode("");
    setState(() {
      _focused = false;
    });
  }

  void handleLongPressEnd(LongPressEndDetails details) {
    deleteNode(tree, details.localPosition / scale);
    setState(() {});
  }
}
