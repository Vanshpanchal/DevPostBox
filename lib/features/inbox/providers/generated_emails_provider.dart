import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hive_service.dart';
import '../../config/providers/config_provider.dart';
import 'inbox_provider.dart';

final generatedEmailsProvider = StateNotifierProvider<GeneratedEmailsNotifier, List<String>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final configState = ref.watch(configNotifierProvider);
  
  String? namespace;
  if (configState is ConfigLoaded) {
    namespace = configState.config.namespace;
  }
  
  return GeneratedEmailsNotifier(hiveService, namespace);
});

class GeneratedEmailsNotifier extends StateNotifier<List<String>> {
  final HiveService _hiveService;
  final String? _namespace;

  GeneratedEmailsNotifier(this._hiveService, this._namespace) : super([]) {
    state = _hiveService.getGeneratedEmails();
  }

  Future<String?> generateNew() async {
    if (_namespace == null || _namespace!.isEmpty) return null;
    final tag = _generateRandomTag();
    final email = '$_namespace$tag.test@.testmail.app';
    
    await _hiveService.addGeneratedEmail(email);
    state = _hiveService.getGeneratedEmails();
    
    return email;
  }

  Future<void> addCustom(String email) async {
    await _hiveService.addGeneratedEmail(email);
    state = _hiveService.getGeneratedEmails();
  }

  Future<void> delete(String email) async {
    await _hiveService.deleteGeneratedEmail(email);
    state = _hiveService.getGeneratedEmails();
  }

  String _generateRandomTag() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
