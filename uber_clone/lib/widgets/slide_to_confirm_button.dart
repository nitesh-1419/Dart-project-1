import 'package:flutter/material.dart';

class SlideToConfirmButton extends StatefulWidget {
  final String text;
  final VoidCallback onConfirm;
  final bool isEnabled;

  const SlideToConfirmButton({
    super.key,
    required this.text,
    required this.onConfirm,
    this.isEnabled = true,
  });

  @override
  State<SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton> {
  double _position = 0;
  final double _sliderWidth = 64;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double trackWidth = maxWidth - _sliderWidth;

        return Opacity(
          opacity: widget.isEnabled ? 1.0 : 0.5,
          child: Container(
            height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'UberMove',
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 4,
                  bottom: 4,
                  child: GestureDetector(
                    onHorizontalDragUpdate: widget.isEnabled
                        ? (details) {
                            setState(() {
                              _position += details.delta.dx;
                              _position = _position.clamp(0.0, trackWidth - 8);
                            });
                          }
                        : null,
                    onHorizontalDragEnd: widget.isEnabled
                        ? (details) {
                            if (_position > (trackWidth - 8) * 0.8) {
                              widget.onConfirm();
                            }
                            setState(() {
                              _position = 0;
                            });
                          }
                        : null,
                    child: Container(
                      width: _sliderWidth - 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(2, 0),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}