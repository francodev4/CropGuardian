import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/insect.dart';
import '../models/detection.dart';
import '../models/treatment.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Insects
  Future<List<Insect>> getInsects({String? category, String? search}) async {
    var query = _supabase.from('insects').select('*');

    // Filtrer par catégorie si ce n'est pas "Tous" ou "All"
    if (category != null && category != 'All' && category != 'Tous') {
      query = query.eq('category', category);
    }

    if (search != null && search.isNotEmpty) {
      query = query
          .or('common_name.ilike.%$search%,scientific_name.ilike.%$search%');
    }

    final response = await query.order('common_name');
    return response.map<Insect>((json) => Insect.fromJson(json)).toList();
  }

  Future<Insect?> getInsectById(String id) async {
    final response =
        await _supabase.from('insects').select('*').eq('id', id).maybeSingle();

    return response != null ? Insect.fromJson(response) : null;
  }

  // Detections
  Future<List<Detection>> getDetections({int limit = 50}) async {
    final response = await _supabase
        .from('detections')
        .select('*')
        .order('created_at', ascending: false)
        .limit(limit);

    return response.map<Detection>((json) => Detection.fromJson(json)).toList();
  }

  Future<void> saveDetection(Detection detection) async {
    await _supabase.from('detections').insert(detection.toJson());
  }

  Future<void> toggleFavorite(String detectionId, bool isFavorite) async {
    await _supabase
        .from('detections')
        .update({'is_favorite': isFavorite}).eq('id', detectionId);
  }

  // Treatments
  Future<List<Treatment>> getTreatmentsForInsect(String insectId) async {
    final response = await _supabase
        .from('traitements')
        .select('*')
        .eq('insect_id', insectId)
        .order('efficacite', ascending: false);

    return response.map<Treatment>((json) => Treatment.fromJson(json)).toList();
  }
}
