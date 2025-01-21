import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/components/custom_text_field.dart';
import 'package:streaks/res/colors.dart';

class CustomDropDownField extends StatefulWidget {
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? value;
  final List<String> items;
  final String title;
  final TextEditingController? controller;
  const CustomDropDownField({
    super.key,
    this.onChanged,
    this.onSaved,
    this.value,
    required this.items,
    required this.title,
    this.controller,
  });

  @override
  State<CustomDropDownField> createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  final controller = TextEditingController();
  bool isShowDropDown = false;
  String selectedValue = "";

  @override
  void initState() {
    selectedValue = widget.value ?? "";
    controller.text = (widget.value == null || widget.value == "" || widget.value == "null") ? "" : (widget.value ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          isReadOnly: true,
          title: widget.title,
          controller: widget.controller ?? controller,
          onPressed: () {
            setState(() {
              isShowDropDown = !isShowDropDown;
            });
          },
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: FlexColor.lightFlexInverseSurface,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: _CustomListTile(
              data: widget.items,
              onChanged: (value) {
                isShowDropDown = !isShowDropDown;
                selectedValue = value;
                controller.text = value;
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
                setState(() {});
              },
              selectedValue: widget.controller?.text ?? selectedValue,
            ),
          ),
          crossFadeState: isShowDropDown ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _CustomListTile extends StatefulWidget {
  final List<String> data;
  final Function(String)? onChanged;
  final String selectedValue;
  const _CustomListTile({
    required this.data,
    required this.onChanged,
    required this.selectedValue,
  });

  @override
  State<_CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<_CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.data
          .asMap()
          .map(
            (index, value) => MapEntry(
              index,
              InkWell(
                onTap: () {
                  widget.onChanged!(widget.data[index]);
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
                            child: Text(
                              widget.data[index],
                              style: GoogleFonts.poppins(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w900,
                                color: widget.selectedValue == widget.data[index] ? AppColors.primaryColor : AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (index + 1 != widget.data.length)
                      const Divider(
                        color: AppColors.greyColor,
                      )
                  ],
                ),
              ),
            ),
          )
          .values
          .toList(),
    );
  }
}
