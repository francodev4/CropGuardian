// lib/features/identification/description_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/database_service.dart';
import '../../core/services/gemini_service.dart';
import '../../core/models/insect.dart';

class DescriptionSearchScreen extends StatefulWidget {
  const DescriptionSearchScreen({super.key});

  @override
  State<DescriptionSearchScreen> createState() =>
      _DescriptionSearchScreenState();
}

class _DescriptionSearchScreenState extends State<DescriptionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final GeminiService _geminiService = GeminiService.instance;
  List<Insect> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _usedAI = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _usedAI = false;
    });

    try {
      // 1️⃣ PRIORITÉ: Utiliser Gemini AI pour l'analyse de description
      print('🤖 Recherche avec Gemini AI: $query');
      
      if (!_geminiService.isInitialized) {
        await _geminiService.initialize();
      }

      if (_geminiService.isInitialized) {
        // Créer un prompt optimisé pour l'identification
        final enhancedQuery = '''
Identifiez l'insecte ou le ravageur agricole décrit par: "$query"

Répondez avec:
1. Le nom français de l'insecte le plus probable
2. Les noms alternatifs possibles
3. Une brève description pour confirmer l'identification

Format: Nom principal, noms alternatifs (séparés par des virgules)
''';
        
        final aiResponse = await _geminiService.askQuestion(enhancedQuery);
        
        // Vérifier si c'est une erreur
        if (!aiResponse.startsWith('Erreur')) {
          print('✅ Réponse Gemini: $aiResponse');
          
          // Parser la réponse AI (String) et chercher dans la base
          final aiResults = await _parseAITextResponseAndSearch(aiResponse);
          
          if (aiResults.isNotEmpty) {
            setState(() {
              _searchResults = aiResults;
              _isSearching = false;
              _usedAI = true;
            });
            print('✅ ${aiResults.length} résultats trouvés via Gemini AI');
            return;
          }
        } else {
          print('⚠️ Erreur Gemini: $aiResponse');
        }
      }

      // 2️⃣ FALLBACK: Recherche dans la base de données locale
      print('🔍 Fallback: Recherche locale pour "$query"');
      final localResults = await _databaseService.getInsects(search: query);
      
      setState(() {
        _searchResults = localResults;
        _isSearching = false;
        _usedAI = false;
      });
      
      if (localResults.isNotEmpty) {
        print('✅ ${localResults.length} résultats trouvés localement');
      } else {
        print('❌ Aucun résultat trouvé');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun insecte trouvé pour cette description'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la recherche: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🤖 Parser la réponse texte de Gemini et chercher les insectes dans la base
  Future<List<Insect>> _parseAITextResponseAndSearch(String aiResponse) async {
    final List<Insect> results = [];
    
    try {
      // Extraire les noms d'insectes de la réponse texte
      // Chercher des mots-clés communs dans la réponse
      final keywords = [
        'puceron', 'thrips', 'doryphore', 'chenille', 'mouche',
        'cochenille', 'aleurode', 'cicadelle', 'pyrale', 'noctuelle',
        'mineuse', 'charançon', 'aphid', 'whitefly', 'beetle'
      ];
      
      final lowerResponse = aiResponse.toLowerCase();
      
      for (var keyword in keywords) {
        if (lowerResponse.contains(keyword)) {
          final matches = await _databaseService.getInsects(search: keyword);
          for (var match in matches) {
            if (!results.any((r) => r.id == match.id)) {
              results.add(match);
            }
          }
        }
      }
    } catch (e) {
      print('❌ Erreur parsing réponse AI: $e');
    }
    
    return results;
  }
  
  // 🤖 Parser la réponse JSON de Gemini (ancienne méthode, conservée pour compatibilité)
  Future<List<Insect>> _parseAIResponseAndSearch(Map<String, dynamic> aiResponse) async {
    final List<Insect> results = [];
    
    try {
      if (aiResponse.containsKey('insects')) {
        final insects = aiResponse['insects'] as List;
        
        for (var insectData in insects) {
          final commonName = insectData['common_name'] as String?;
          final scientificName = insectData['scientific_name'] as String?;
          
          // Chercher dans la base par nom commun
          if (commonName != null) {
            final matches = await _databaseService.getInsects(search: commonName);
            results.addAll(matches);
          }
          
          // Chercher aussi par nom scientifique
          if (scientificName != null && results.length < 5) {
            final matches = await _databaseService.getInsects(search: scientificName);
            for (var match in matches) {
              if (!results.any((r) => r.id == match.id)) {
                results.add(match);
              }
            }
          }
        }
      }
    } catch (e) {
      print('❌ Erreur parsing réponse AI: $e');
    }
    
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche par description'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Décrivez l\'insecte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ex: petit insecte vert, ailes transparentes, puce, mouche, etc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Entrez une description...',
                    prefixIcon:
                        Icon(Icons.search, color: theme.colorScheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _hasSearched = false;
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                  onSubmitted: (value) => _performSearch(),
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _performSearch,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? 'Recherche...' : 'Rechercher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Résultats
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Décrivez l\'insecte que vous recherchez',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les résultats apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez avec d\'autres mots-clés',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final insect = _searchResults[index];
        return _InsectCard(insect: insect);
      },
    );
  }
}

class _InsectCard extends StatelessWidget {
  final Insect insect;

  const _InsectCard({required this.insect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: () {
          context.push('/insect/${insect.id}', extra: insect);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: insect.imageUrl != null && insect.imageUrl!.isNotEmpty
                    ? Image.network(
                        insect.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.bug_report, size: 40, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.bug_report, size: 40, color: theme.colorScheme.onSurfaceVariant),
                      ),
              ),
              const SizedBox(width: 12),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insect.commonName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insect.scientificName,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: insect.category == 'Nuisible'
                            ? Colors.red.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        insect.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: insect.category == 'Nuisible'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Flèche
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
