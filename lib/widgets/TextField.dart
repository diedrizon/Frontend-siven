import 'package:flutter/material.dart';

// Clase singleton para gestionar los dropdowns abiertos
class DropdownManager {
  static final DropdownManager _singleton = DropdownManager._internal();

  factory DropdownManager() {
    return _singleton;
  }

  DropdownManager._internal();

  _CustomTextFieldDropdownState? _currentOpenDropdown;

  void registerOpenDropdown(_CustomTextFieldDropdownState dropdown) {
    if (_currentOpenDropdown != null && _currentOpenDropdown != dropdown) {
      _currentOpenDropdown!._closeDropdown();
    }
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
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
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    setState(() {
      _isDropdownOpen = true;
    });

    // Registrar este dropdown como el abierto actualmente
    DropdownManager().registerOpenDropdown(this);

    // Escuchar cambios de foco
    _focusNode.addListener(_handleFocusChange);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    setState(() {
      _isDropdownOpen = false;
    });

    // Remover el listener de foco
    _focusNode.removeListener(_handleFocusChange);

    // Desregistrar este dropdown
    DropdownManager().unregisterOpenDropdown(this);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _closeDropdown();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200, // Altura máxima del desplegable
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.options.map((option) {
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      widget.controller.text = option;
                      _closeDropdown();

                      // Ejecutar la función onChanged si está definida
                      if (widget.onChanged != null) {
                        widget.onChanged!(option);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
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
                    _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Color(0xFF4A4A4A),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: widget.borderColor),
                    onPressed: () {
                      widget.controller.clear();
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                    color: widget.borderColor, width: widget.borderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                    color: widget.borderColor, width: widget.borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                    color: widget.borderColor, width: widget.borderWidth),
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
