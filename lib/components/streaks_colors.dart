import 'package:flutter/material.dart';
import 'package:streaks/res/constants.dart';

class StreaksColors extends StatefulWidget {
  final int? initialColor;
  final Function(int selectedPrimary, int selectedContainer) onColorSelected;

  const StreaksColors({
    super.key,
    this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<StreaksColors> createState() => _StreaksColorsState();
}

class _StreaksColorsState extends State<StreaksColors> {
  int? selectedColorCode;

  @override
  void initState() {
    super.initState();
    selectedColorCode = widget.initialColor ?? AppConstants.colors.first.value;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: AppConstants.colors.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColorCode = AppConstants.colors[index].value;
            });
            widget.onColorSelected(AppConstants.colors[index].value, AppConstants.primaryContainerColors[index].value);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ColorCircle(
                color: AppConstants.colors[index],
              ),
              if (selectedColorCode == AppConstants.colors[index].value)
                Container(
                  height: 10.0,
                  width: 10.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;
  const ColorCircle({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3.0),
      height: 40.0,
      width: 40.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
