// lib/features/history/history_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/database_service.dart';
import '../../core/models/detection.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _database = DatabaseService();
  List<Detection> detections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    try {
      final result = await _database.getDetections();
      setState(() {
        detections = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Détections'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detections.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          size: 64, color: AppColors.textTertiary),
                      SizedBox(height: 16),
                      Text(
                        'No detections yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: detections.length,
                  itemBuilder: (context, index) {
                    final detection = detections[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: const Icon(Icons.bug_report,
                              color: AppColors.primary),
                        ),
                        title: Text(detection.insectName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(detection.scientificName,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic)),
                            Text(
                                'Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            detection.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: detection.isFavorite ? Colors.red : null,
                          ),
                          onPressed: () async {
                            await _database.toggleFavorite(
                                detection.id, !detection.isFavorite);
                            _loadHistory();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
