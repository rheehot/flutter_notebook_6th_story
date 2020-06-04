import 'package:flutter/material.dart';
import 'package:flutternotebook6thstory/ep463_waching_machine/ui/inner_shadow_decorator.dart';
import 'package:flutternotebook6thstory/ep463_waching_machine/ui/neumorphic_container.dart';
import 'package:flutternotebook6thstory/ep463_waching_machine/utils/colors.dart';

typedef ValueChangeCallback = void Function(double value);

class WaterSlider extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double initValue;
  final ValueChangeCallback onValueChanged;

  WaterSlider({Key key, @required this.minValue, @required this.maxValue, this.initValue, this.onValueChanged})
      : super(key: key) {
    assert(minValue < maxValue);
    assert(minValue >= 0);
    assert(maxValue >= 0);
  }

  @override
  _WaterSliderState createState() => _WaterSliderState();
}

class _WaterSliderState extends State<WaterSlider> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(50);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: [
            NeumorphicContainer(
              width: 85,
              color: CustomColors.containerPressed,
              borderRadius: borderRadius,
              disableForegroundDecoration: true,
              padding: EdgeInsets.zero,
              child: Container(
                decoration: InnerShadowDecoration(
                  colors: [
                    CustomColors.containerInnerShadowTop,
                    CustomColors.containerInnerShadowBottom,
                  ],
                  borderRadius: borderRadius,
                ),
                child: Stack(
                  children: [
                    _WaterSlide(
                      height: constraints.maxHeight,
                      min: widget.minValue,
                      max: widget.maxValue,
                      controller: _animationController,
                      topOffset: 40,
                      bottomOffset: 58,
                      initValue: widget.initValue,
                      onValueChanged: widget?.onValueChanged,
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class _WaterSlide extends StatefulWidget {
  final double height;
  final double min;
  final double max;
  final double topOffset;
  final double bottomOffset;
  final double initValue;
  final Animation<double> controller;
  final ValueChangeCallback onValueChanged;

  _WaterSlide(
      {this.height,
      this.min,
      this.max,
      this.topOffset = 0.0,
      this.bottomOffset = 0.0,
      this.initValue,
      this.controller,
      this.onValueChanged});

  @override
  __WaterSlideState createState() => __WaterSlideState();
}

class __WaterSlideState extends State<_WaterSlide> {
  Animation _growAnimation;
  double _yOffset = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    double animationEndValue =
        widget.initValue == null ? _validateYOffset(_yOffset) : _validateYOffset(_calculateYOffset(widget.initValue));

    _growAnimation = Tween<double>(begin: widget.height, end: animationEndValue)
        .animate(CurvedAnimation(parent: widget.controller, curve: Interval(0.350, 0.750, curve: Curves.easeOutCubic)))
          ..addListener(() {
            setState(() {
              _yOffset = _growAnimation.value;
            });
          });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _yOffset = _validateYOffset(_yOffset + details.delta.dy);
      _calculateValue();
    });
  }

  double _validateYOffset(double newYOffset) {
    double result = newYOffset;
    if (result < widget.topOffset) {
      result = widget.topOffset;
    }
    if (result > widget.height - widget.bottomOffset) {
      result = widget.height - widget.bottomOffset;
    }
    return result;
  }

  void _calculateValue() {
    double workingH = widget.height - widget.topOffset - widget.bottomOffset;
    double currentH = widget.height - widget.bottomOffset - _yOffset;
    double factor = workingH / (widget.max - widget.min);
    double value = (currentH + (widget.min * factor)) / factor;
    if (widget.onValueChanged != null) {
      widget.onValueChanged(value);
    }
  }

  double _calculateYOffset(double value) {
    double workingH = widget.height - widget.topOffset - widget.bottomOffset;
    double factor = workingH / (widget.max - widget.min);

    double result = -((value * factor) - widget.height + widget.bottomOffset - (widget.min * factor));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -_yOffset,
      left: 0,
      child: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        child: Stack(
          children: [],
        ),
      ),
    );
  }
}
