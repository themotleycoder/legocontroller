import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SpeedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const SpeedButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: MaterialButton(
        onPressed: onPressed,
        color: color,
        disabledColor: Colors.grey,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const ControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: MaterialButton(
        onPressed: onPressed,
        color: color,
        disabledColor: Colors.grey,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}