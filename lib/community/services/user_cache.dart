import 'package:supabase_flutter/supabase_flutter.dart';

class UserCache {
  // ✅ Singleton instance
  UserCache._();
  static final UserCache instance = UserCache._();

  final _supabase = Supabase.instance.client;
  final Map<String, String> _cache = {};

  Future<String> getUserName(String userId) async {
    if (_cache.containsKey(userId)) {
      return _cache[userId]!;
    }

    final data = await _supabase
        .from('users')
        .select('name')
        .eq('id', userId)
        .maybeSingle();

    final name = data?['name'] ?? 'Unknown';
    _cache[userId] = name;
    return name;
  }
}
