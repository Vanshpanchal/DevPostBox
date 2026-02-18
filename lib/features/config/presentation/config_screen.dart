/// API Configuration Screen
/// First-launch screen for entering API credentials
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/config_provider.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  final bool isSettings;

  const ConfigScreen({super.key, this.isSettings = false});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _namespaceController = TextEditingController();

  bool _isLoading = false;
  bool _isTesting = false;
  bool _obscureApiKey = true;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    final storageService = ref.read(secureStorageProvider);
    final config = await storageService.getApiConfig();
    if (config != null && mounted) {
      setState(() {
        _baseUrlController.text = config.baseUrl;
        _apiKeyController.text = config.apiKey;
        _namespaceController.text = config.namespace;
      });
    } else {
      _baseUrlController.text = AppConstants.defaultBaseUrl;
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _namespaceController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      // Temporarily save and test
      final tempConfig = ApiConfig(
        apiKey: _apiKeyController.text.trim(),
        baseUrl: _baseUrlController.text.trim(),
        namespace: _namespaceController.text.trim(),
      );
      await ref.read(secureStorageProvider).saveApiConfig(tempConfig);

      final apiService = ApiService(
        storageService: ref.read(secureStorageProvider),
      );
      await apiService.testConnection();

      if (mounted) {
        setState(() {
          _testResult = '✓ Connection successful!';
          _testSuccess = true;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _testResult = '✗ ${e.message}';
          _testSuccess = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testResult = '✗ Connection failed';
          _testSuccess = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(configNotifierProvider.notifier)
        .saveConfiguration(
          apiKey: _apiKeyController.text.trim(),
          baseUrl: _baseUrlController.text.trim(),
          namespace: _namespaceController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        if (widget.isSettings) {
          Navigator.of(context).pop(true);
        }
        // Navigation handled by app.dart based on config state
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save configuration'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _clearConfiguration() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Configuration?'),
        content: const Text(
          'This will remove your API credentials. You will need to re-enter them to use the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(configNotifierProvider.notifier).clearConfiguration();
      if (widget.isSettings && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSettings ? 'Settings' : 'Configure API'),
        leading: widget.isSettings
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                if (!widget.isSettings) ...[
                  Icon(
                    Icons.mail_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DevPostBox',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your testmail.app API credentials',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],

                // API Base URL
                TextFormField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'https://api.testmail.app/api/json',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the API URL';
                    }
                    if (!value.startsWith('http')) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // API Key
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'Your testmail.app API key',
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscureApiKey = !_obscureApiKey);
                      },
                    ),
                  ),
                  obscureText: _obscureApiKey,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your API key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Namespace
                TextFormField(
                  controller: _namespaceController,
                  decoration: const InputDecoration(
                    labelText: 'Namespace',
                    hintText: 'e.g., aaaaa',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your namespace';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Test Connection Button
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                ),

                // Test Result
                if (_testResult != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _testSuccess
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        color: _testSuccess
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveConfiguration,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save & Connect'),
                ),

                // Clear Config (only in settings)
                if (widget.isSettings) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _clearConfiguration,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Configuration'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Security Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your credentials are encrypted and stored securely on this device only.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
