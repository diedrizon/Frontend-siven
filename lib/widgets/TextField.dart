// Archivo: widgets/custom_text_field_dropdown.dart

import 'package:flutter/material.dart';

class CustomTextFieldDropdown extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final List<String> options;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double width;
  final double height;
  final Function(String)? onChanged;  // Nuevo parámetro para manejar los cambios de selección

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
    this.onChanged,  // Asegúrate de incluir onChanged aquí
  }) : super(key: key);

  @override
  _CustomTextFieldDropdownState createState() => _CustomTextFieldDropdownState();
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

    // Cerrar el dropdown si se pierde el foco
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _closeDropdown();
      }
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
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
                borderSide: BorderSide(color: widget.borderColor, width: widget.borderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: widget.borderColor, width: widget.borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: widget.borderColor, width: widget.borderWidth),
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
