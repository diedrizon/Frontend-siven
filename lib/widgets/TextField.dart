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
  final Function(String)? onChanged;
  final TextStyle? dropdownTextStyle;

  const CustomTextFieldDropdown({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.options,
    this.borderColor = Colors.orange, // Color por defecto del borde
    this.borderWidth = 2.0,
    this.borderRadius = 5.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.onChanged,
    this.dropdownTextStyle,
  }) : super(key: key);

  @override
  _CustomTextFieldDropdownState createState() =>
      _CustomTextFieldDropdownState();
}

class _CustomTextFieldDropdownState extends State<CustomTextFieldDropdown> {
  bool _isDropdownOpen = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredOptions;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() {
      _isDropdownOpen = true;
      _filteredOptions = widget.options; // Inicializa opciones sin filtrar
    });
  }

  void _closeDropdown() {
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _filterOptions(String query) {
    setState(() {
      _filteredOptions = widget.options
          .where((option) =>
              option.toLowerCase().contains(query.toLowerCase())) // Filtrar
          .toList();
    });
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
    _filteredOptions = widget.options; // Inicializa con todas las opciones
    _searchController.addListener(() {
      _filterOptions(_searchController.text);
    });
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.dispose();
    _searchController.dispose();
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
                suffixIcon: Icon(
                  _isDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: widget.borderColor, // Color dinámico del ícono
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor, // Color dinámico del borde
                    width: widget.borderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor, // Color dinámico del borde
                    width: widget.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor, // Color dinámico del borde
                    width: widget.borderWidth,
                  ),
                ),
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
            child: Column(
              children: [
                // Campo de búsqueda dentro del dropdown
                ListTile(
                  title: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar...",
                      prefixIcon: Icon(Icons.search, color: widget.borderColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Divider(),
                // Opciones filtradas dinámicamente
                ListView(
                  shrinkWrap: true,
                  children: _filteredOptions.map((option) {
                    return ListTile(
                      title: Text(
                        option,
                        style: widget.dropdownTextStyle ??
                            TextStyle(
                              fontSize: 16,
                              color: Colors.black, // Color del texto
                            ),
                      ),
                      onTap: () => _handleOptionTap(option),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
