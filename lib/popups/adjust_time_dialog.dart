import 'package:flutter/material.dart';

typedef OnAdjustTime = void Function(dynamic order, int timeAdjustment);

class AdjustTimeDialog extends StatefulWidget {
  final dynamic order;
  final OnAdjustTime onAdjustTime;

  const AdjustTimeDialog({
    super.key,
    required this.order,
    required this.onAdjustTime,
  });

  @override
  State<AdjustTimeDialog> createState() => _AdjustTimeDialogState();
}

class _AdjustTimeDialogState extends State<AdjustTimeDialog> {
  int timeAdjustment = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adjust Delivery Time'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                timeAdjustment-= 5;
              });
            },
          ),
          Text('$timeAdjustment mins'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                timeAdjustment+= 5;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Adjust'),
          onPressed: () {
            widget.onAdjustTime(widget.order, timeAdjustment);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
