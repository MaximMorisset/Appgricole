import 'package:flutter/material.dart';

class CheckboxWidget extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;

  const CheckboxWidget({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onChanged(_isChecked);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          _isChecked ? Icons.check_box : Icons.check_box_outline_blank,
          color: _isChecked ? Colors.black : Colors.black,
        ),
      ),
    );
  }
}
