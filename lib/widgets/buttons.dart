import 'package:flutter/material.dart';

class SpeedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool small;

  const SpeedButton({super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: small ? 32 : 40,
      height: small ? 32 : 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          minimumSize: Size(small ? 32 : 40, small ? 32 : 40),
        ),
        child: Icon(
          icon,
          size: small ? 18 : 24,
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
  final bool small;

  const ControlButton({super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: small ? 32 : 40,
      height: small ? 32 : 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          minimumSize: Size(small ? 32 : 40, small ? 32 : 40),
        ),
        child: Icon(
          icon,
          size: small ? 18 : 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
