import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const WeetApp());
}

class WeetApp extends StatelessWidget {
  const WeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weet',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5C6AC4),
      ),
      home: const WeetHomePage(),
    );
  }
}

class Person {
  Person({
    required this.name,
    required this.category,
    required this.score,
  });

  final String name;
  final String category;
  final int score;
}

class WeetHomePage extends StatefulWidget {
  const WeetHomePage({super.key});

  @override
  State<WeetHomePage> createState() => _WeetHomePageState();
}

class _WeetHomePageState extends State<WeetHomePage> {
  final List<String> _categories = <String>[
    'Family',
    'Friends',
    'Business',
    'Other',
  ];

  final List<Person> _people = <Person>[
    Person(name: 'Mom', category: 'Family', score: 95),
    Person(name: 'Alex', category: 'Friends', score: 70),
    Person(name: 'Chris', category: 'Business', score: 40),
  ];

  String _selectedCategory = 'All';

  List<Person> get _visiblePeople {
    if (_selectedCategory == 'All') {
      return _people;
    }
    return _people
        .where((Person person) => person.category == _selectedCategory)
        .toList();
  }

  Future<void> _openAddCategoryDialog() async {
    final TextEditingController controller = TextEditingController();

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Category name',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.of(context).pop(controller.text.trim()),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    if (_categories.contains(result)) {
      _showSnackBar('Category already exists.');
      return;
    }

    setState(() {
      _categories.add(result);
    });
  }

  Future<void> _openAddPersonDialog() async {
    final TextEditingController nameController = TextEditingController();

    String category = _categories.first;
    int score = 50;
    int? checklistValue;

    final Person? person = await showDialog<Person>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return AlertDialog(
              title: const Text('Add Person'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (String cat) => DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          category = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Relationship Score: $score',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Slider(
                      min: 0,
                      max: 100,
                      divisions: 100,
                      value: score.toDouble(),
                      label: '$score',
                      onChanged: (double value) {
                        setDialogState(() {
                          checklistValue = null;
                          score = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick checklist',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: <int>[20, 40, 60, 80, 100]
                          .map(
                            (int value) => ChoiceChip(
                              label: Text('$value'),
                              selected: checklistValue == value,
                              onSelected: (_) {
                                setDialogState(() {
                                  checklistValue = value;
                                  score = value;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final String name = nameController.text.trim();
                    if (name.isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop(
                      Person(name: name, category: category, score: score),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (person == null) {
      return;
    }

    setState(() {
      _people.add(person);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weet Relationship Map'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add category',
            onPressed: _openAddCategoryDialog,
            icon: const Icon(Icons.category_outlined),
          ),
          IconButton(
            tooltip: 'Add person',
            onPressed: _openAddPersonDialog,
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          _CategoryFilterBar(
            categories: <String>['All', ..._categories],
            selectedCategory: _selectedCategory,
            onSelect: (String value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: RelationshipMap(people: _visiblePeople),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final String category = categories[index];
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (_) => onSelect(category),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}

class RelationshipMap extends StatelessWidget {
  const RelationshipMap({super.key, required this.people});

  final List<Person> people;

  static const List<Color> _palette = <Color>[
    Color(0xFF6750A4),
    Color(0xFF00796B),
    Color(0xFF5D4037),
    Color(0xFF1976D2),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double size = math.min(constraints.maxWidth, constraints.maxHeight);
        final Offset center = Offset(size / 2, size / 2);
        final double maxRadius = size / 2 - 24;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: <Widget>[
                CustomPaint(
                  size: Size(size, size),
                  painter: _MapRingsPainter(),
                ),
                Positioned(
                  left: center.dx - 26,
                  top: center.dy - 26,
                  child: _CenterNode(),
                ),
                ...people.asMap().entries.map((MapEntry<int, Person> entry) {
                  final int index = entry.key;
                  final Person person = entry.value;
                  final double angle = (2 * math.pi / math.max(1, people.length)) * index;
                  final double radiusFactor = (100 - person.score) / 100;
                  final double radius = (radiusFactor * maxRadius).clamp(28, maxRadius);

                  final double x = center.dx + math.cos(angle) * radius;
                  final double y = center.dy + math.sin(angle) * radius;

                  return Positioned(
                    left: x - 36,
                    top: y - 20,
                    child: _PersonChip(
                      person: person,
                      color: _palette[index % _palette.length],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double baseRadius = size.width / 2 - 8;

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.black12;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, baseRadius * (i / 4), ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CenterNode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      alignment: Alignment.center,
      child: const Text(
        'Me',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PersonChip extends StatelessWidget {
  const _PersonChip({required this.person, required this.color});

  final Person person;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            person.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            '${person.category} • ${person.score}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
