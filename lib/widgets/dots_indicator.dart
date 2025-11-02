import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int count;
  final int position;
  const DotsIndicator({required this.count, required this.position});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == position;
        // hide on last
        if (position == count - 1) return SizedBox.shrink();
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          width: selected ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? Color(0xFF7C3AED) : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
