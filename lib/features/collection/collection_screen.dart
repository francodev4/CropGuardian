// lib/features/collection/collection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Use Theme colors instead of AppColors for light/dark support
import '../../core/services/database_service.dart';
import '../../core/models/insect.dart';
import '../../core/widgets/insect_image.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final DatabaseService _database = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Insect> insects = [];
  List<String> categories = [
    'Tous',
    'Coleoptera',
    'Diptera',
    'Lepidoptera',
    'Hemiptera'
  ];
  String selectedCategory = 'Tous';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsects();
  }

  Future<void> _loadInsects() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    
    try {
      final result = await _database.getInsects(
        category: selectedCategory,
        search: _searchController.text,
      );
      
      if (mounted) {
        setState(() {
          insects = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COLLECTION\nD\'INSECTES'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _loadInsects(),
              decoration: InputDecoration(
                hintText: 'Rechercher des insectes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (mounted) {
                        setState(() {
                          selectedCategory = category;
                        });
                        _loadInsects();
                      }
                    },
                    selectedColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // Insects Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int crossAxisCount = 2;
                    double aspect = 0.78; // slightly taller cards for phones

                    // Keep cards readable on small phones by capping min width
                    const cardMinWidth = 150.0;
                    final computedCount = (width / cardMinWidth).floor();
                    if (computedCount >= 2) {
                      crossAxisCount = computedCount.clamp(2, 4);
                    }

                    if (width > 900) {
                      crossAxisCount = 4;
                      aspect = 0.95;
                    } else if (width > 600 && crossAxisCount < 4) {
                      crossAxisCount = crossAxisCount == 2 ? 3 : crossAxisCount;
                      aspect = 0.9;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspect,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: insects.length,
                      itemBuilder: (context, index) {
                        final insect = insects[index];
                        return _InsectCard(
                          insect: insect,
                          onTap: () => context.push('/insect/${insect.id}',
                              extra: insect),
                        );
                      },
                    );
                  }),
          ),
        ],
      ),
    );
  }
}

class _InsectCard extends StatelessWidget {
  final Insect insect;
  final VoidCallback onTap;

  const _InsectCard({required this.insect, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: InsectImage(
                imageUrl: insect.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    insect.commonName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insect.scientificName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      insect.category,
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
