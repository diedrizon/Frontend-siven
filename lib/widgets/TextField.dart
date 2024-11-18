import 'package:flutter/material.dart';

// Clase singleton para gestionar los dropdowns abiertos y cerrar el teclado
class DropdownManager {
  static final DropdownManager _singleton = DropdownManager._internal();

  factory DropdownManager() {
    return _singleton;
  }

  DropdownManager._internal();

  _CustomTextFieldDropdownState? _currentOpenDropdown;

  void registerOpenDropdown(_CustomTextFieldDropdownState dropdown) {
    // Cierra cualquier dropdown abierto
    if (_currentOpenDropdown != null && _currentOpenDropdown != dropdown) {
      _currentOpenDropdown!._closeDropdown();
    }
    // Cierra el teclado
    FocusManager.instance.primaryFocus?.unfocus();
    _currentOpenDropdown = dropdown;
  }

  void unregisterOpenDropdown(_CustomTextFieldDropdownState dropdown) {
    if (_currentOpenDropdown == dropdown) {
      _currentOpenDropdown = null;
    }
  }
}

class CustomTextFieldDropdown extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final List<String> options;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double width;
  final double height;
  final Function(String)? onChanged;

  const CustomTextFieldDropdown({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.options,
    this.borderColor = Colors.orange,
    this.borderWidth = 2.0,
    this.borderRadius = 5.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomTextFieldDropdownState createState() =>
      _CustomTextFieldDropdownState();
}

class _CustomTextFieldDropdownState extends State<CustomTextFieldDropdown> {
  bool _isDropdownOpen = false;
  final FocusNode _focusNode = FocusNode();

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    // Registra este dropdown como el actualmente abierto
    DropdownManager().registerOpenDropdown(this);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    setState(() {
      _isDropdownOpen = false;
    });
    DropdownManager().unregisterOpenDropdown(this);
  }

  void _handleOptionTap(String option) {
    widget.controller.text = option;
    _closeDropdown();
    if (widget.onChanged != null) {
      widget.onChanged!(option);
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isDropdownOpen) {
        _closeDropdown();
      }
    });
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleDropdown,
          child: AbsorbPointer(
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isDropdownOpen
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: const Color(0xFF4A4A4A),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: widget.borderColor),
                      onPressed: () {
                        widget.controller.clear();
                        if (widget.onChanged != null) {
                          widget.onChanged!('');
                        }
                      },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor,
                    width: widget.borderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor,
                    width: widget.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor,
                    width: widget.borderWidth,
                  ),
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
        if (_isDropdownOpen)
          Container(
            width: widget.width,
            decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: Colors.white,
            ),
            child: ListView(
              shrinkWrap: true,
              children: widget.options.map((option) {
                return ListTile(
                  title: Text(option),
                  onTap: () => _handleOptionTap(option),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
