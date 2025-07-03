import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Flushbar<dynamic>? _currentFlushbar;

Future<void> showTopMessage(BuildContext context, String message) async {
  // 중복 방지
  _currentFlushbar?.dismiss();

  final flushbar = Flushbar(
    message: message,
    icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
    margin: const EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: Colors.grey[900]!,
    duration: const Duration(seconds: 1),
    flushbarPosition: FlushbarPosition.TOP,
    animationDuration: const Duration(milliseconds: 400),
  );

  _currentFlushbar = flushbar;
  await flushbar.show(context);
  _currentFlushbar = null;
}
