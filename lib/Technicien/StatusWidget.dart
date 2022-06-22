import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

class StatusWidget extends StatefulWidget {
  final int status;

  const StatusWidget({
    required this.status,
  });
  @override
  _StatusWidgetState createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  //

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: (widget.status == 1
                ? const Icon(Icons.lightbulb, color: Colors.green)
                : widget.status == 0
                    ? const Icon(
                        Icons.lightbulb,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.lightbulb,
                        color: Colors.grey,
                      )),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
