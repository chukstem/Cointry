import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:crypto_app/constants.dart';

class AppIndicator extends StatelessWidget {
  AppIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.r,
      width: 50.r,
      child: LoadingIndicator(
        indicatorType: Indicator.ballRotateChase,
        colors: indicators,
        strokeWidth: 3,
        backgroundColor: Colors.transparent,
        pathBackgroundColor: Colors.black,
      ),
    );
  }
}

class ContainerIndicator extends StatelessWidget {
  ContainerIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: AppIndicator(),
    );
  }
}

class WrapperIndicator extends StatefulWidget {
  final bool loading;
  final Widget child;
  WrapperIndicator({
    Key? key,
    this.loading = false,
    required this.child,
  }) : super(key: key);

  @override
  State<WrapperIndicator> createState() => _WrapperIndicatorState();
}

class _WrapperIndicatorState extends State<WrapperIndicator> {
  bool loading = false;

  @override
  void didUpdateWidget(WrapperIndicator oldWidget) {
    if (oldWidget.loading != widget.loading) {
      setState(() {
        loading = widget.loading;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   key: ValueKey<bool>(widget.loading),
    //   children: [
    //     widget.child,
    //     widget.loading
    //         ? Positioned(
    //             top: 0,
    //             left: 0,
    //             right: 0,
    //             bottom: 0,
    //             child: ContainerIndicator(),
    //           )
    //         : SizedBox(),
    //   ],
    // );

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: Tween(begin: 0.7, end: 1.0).animate(animation),
            child: child,
          );
        },
        child: Stack(
          key: ValueKey<bool>(widget.loading),
          children: [
            widget.child,
            widget.loading
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ContainerIndicator(),
                  )
                : SizedBox(),
          ],
        ));
  }
}
