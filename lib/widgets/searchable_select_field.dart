import 'package:flutter/material.dart';

/// A form field that opens a searchable list. Typing filters the options,
/// e.g. "fo" shows Food, Footwear... with names starting "fo" listed first.
class SearchableSelectField extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<({int id, String name})> options;
  final int? value;
  final ValueChanged<int?> onChanged;
  final FormFieldValidator<int>? validator;
  final FormFieldSetter<int>? onSaved;

  const SearchableSelectField({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
    this.onSaved,
  });

  String? get _selectedName {
    for (final o in options) {
      if (o.id == value) return o.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Keyed by value so programmatic changes (scan, clear) refresh the field.
    return FormField<int>(
      key: ValueKey('$label-$value-${options.length}'),
      initialValue: value,
      validator: validator,
      onSaved: onSaved,
      builder: (state) {
        final name = _selectedName;
        return InkWell(
          onTap: () async {
            final picked = await _showPicker(context);
            if (picked != null) {
              state.didChange(picked);
              onChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              errorText: state.errorText,
            ),
            isEmpty: name == null,
            child: Text(name ?? '', overflow: TextOverflow.ellipsis),
          ),
        );
      },
    );
  }

  Future<int?> _showPicker(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _PickerSheet(label: label, options: options, selected: value),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  final String label;
  final List<({int id, String name})> options;
  final int? selected;

  const _PickerSheet({required this.label, required this.options, required this.selected});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  List<({int id, String name})> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    final starts = <({int id, String name})>[];
    final contains = <({int id, String name})>[];
    for (final o in widget.options) {
      final n = o.name.toLowerCase();
      if (n.startsWith(q)) {
        starts.add(o);
      } else if (n.contains(q)) {
        contains.add(o);
      }
    }
    return [...starts, ...contains];
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search ${widget.label.toLowerCase()}',
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No matches'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final o = items[i];
                        return ListTile(
                          title: Text(o.name),
                          selected: o.id == widget.selected,
                          trailing: o.id == widget.selected ? const Icon(Icons.check) : null,
                          onTap: () => Navigator.pop(context, o.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
