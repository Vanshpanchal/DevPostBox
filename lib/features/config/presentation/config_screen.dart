/// API Configuration Screen
/// First-launch screen for entering API credentials
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/responsive_layout.dart';
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
    _namespaceController.addListener(() {
      setState(() {});
    });
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
      final tempConfig = ApiConfig(
        apiKey: _apiKeyController.text.trim(),
        baseUrl: _baseUrlController.text.trim(),
        namespace: _namespaceController.text.trim(),
      );

      // Test directly with the in-memory config — no storage write needed,
      // so there is no async race between write and read.
      final apiService = ApiService(
        storageService: ref.read(secureStorageProvider),
      );
      await apiService.testConnectionWithConfig(tempConfig);

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

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    if (widget.isSettings) {
      // Settings is always a centred card regardless of platform
      return _buildSettingsLayout(context, isDesktop);
    }

    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else if (isTablet) {
      return _buildTabletLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  // ── Desktop: two-pane (branding left, form right) ────────────────────────

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        children: [
          // Left branding panel
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 56,
                    vertical: 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo mark
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.mail_outline,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const Spacer(flex: 2),
                      const Text(
                        'DevPostBox',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A developer-focused inbox\nfor testmail.app',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildFeatureRow(
                        Icons.bolt_outlined,
                        'Instant delivery',
                        'Emails arrive in real-time',
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureRow(
                        Icons.tag,
                        'Tag-based organisation',
                        'Filter by any tag prefix',
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureRow(
                        Icons.security_outlined,
                        'Secure credentials',
                        'Encrypted on-device storage',
                      ),
                      const Spacer(flex: 3),
                      // Footer link
                      InkWell(
                        onTap: _launchTestmail,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.open_in_new,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'testmail.app — get your free API key',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right form panel
          Expanded(
            flex: 4,
            child: Container(
              color: AppColors.backgroundLight,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 56,
                      vertical: 48,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildForm(context, isDesktop: true),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tablet: centred card layout ───────────────────────────────────────────

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: AppColors.dividerLight),
                ),
                color: AppColors.surfaceLight,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: _buildForm(
                    context,
                    isDesktop: false,
                    showHeader: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Mobile: simple scroll ────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Configure API'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildForm(context, isDesktop: false, showHeader: true),
        ),
      ),
    );
  }

  // ── Settings layout ──────────────────────────────────────────────────────

  Widget _buildSettingsLayout(BuildContext context, bool isDesktop) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: isDesktop
                  ? Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: AppColors.dividerLight),
                      ),
                      color: AppColors.surfaceLight,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: _buildForm(
                          context,
                          isDesktop: true,
                          showHeader: false,
                          isSettings: true,
                        ),
                      ),
                    )
                  : _buildForm(
                      context,
                      isDesktop: false,
                      showHeader: false,
                      isSettings: true,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared form content ──────────────────────────────────────────────────

  Widget _buildForm(
    BuildContext context, {
    required bool isDesktop,
    bool showHeader = false,
    bool isSettings = false,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DevPostBox',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'Connect your testmail.app account',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],

          // Desktop heading (no icon, inline title on left panel)
          if (isDesktop && !showHeader && !isSettings) ...[
            const Text(
              'Connect your account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your testmail.app API credentials below.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
          ],

          // testmail.app link banner
          _buildTestmailBanner(context),
          const SizedBox(height: 24),

          // API Base URL
          _buildSectionLabel('API Base URL'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _baseUrlController,
            decoration: _inputDecoration(
              label: 'https://api.testmail.app/api/json',
              icon: Icons.link_rounded,
            ),
            keyboardType: TextInputType.url,
            style: const TextStyle(fontSize: 14),
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
          const SizedBox(height: 20),

          // API Key
          _buildSectionLabel('API Key'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _apiKeyController,
            decoration:
                _inputDecoration(
                  label: 'Your secret API key',
                  icon: Icons.key_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureApiKey
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                    onPressed: () =>
                        setState(() => _obscureApiKey = !_obscureApiKey),
                  ),
                ),
            obscureText: _obscureApiKey,
            style: const TextStyle(fontSize: 14),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your API key';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Namespace
          _buildSectionLabel('Namespace'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _namespaceController,
            decoration: _inputDecoration(
              label: 'e.g., aaaaa',
              icon: Icons.folder_outlined,
            ),
            style: const TextStyle(fontSize: 14),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your namespace';
              }
              return null;
            },
          ),

          // Live email address preview
          if (_namespaceController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.alternate_email,
                    size: 16,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'anything@${_namespaceController.text.trim()}.testmail.app',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Action row: Test + Save side-by-side on desktop
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildTestButton()),
                const SizedBox(width: 12),
                Expanded(child: _buildSaveButton()),
              ],
            )
          else ...[
            _buildTestButton(),
            const SizedBox(height: 12),
            _buildSaveButton(),
          ],

          // Test result feedback
          if (_testResult != null) ...[
            const SizedBox(height: 12),
            _buildTestResult(),
          ],

          // Clear (settings only)
          if (isSettings) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _clearConfiguration,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear Configuration'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Security note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Your credentials are encrypted and stored securely on this device only.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable sub-widgets ─────────────────────────────────────────────────

  Widget _buildTestmailBanner(BuildContext context) {
    return InkWell(
      onTap: _launchTestmail,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.open_in_new,
              size: 16,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Get your free API key at testmail.app',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.primaryLight.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
        letterSpacing: 0.2,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
        color: AppColors.textSecondaryLight,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondaryLight),
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildTestButton() {
    return OutlinedButton.icon(
      onPressed: _isTesting ? null : _testConnection,
      icon: _isTesting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.wifi_tethering_rounded, size: 18),
      label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.primaryLight),
        foregroundColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveConfiguration,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Save & Connect',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
    );
  }

  Widget _buildTestResult() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: (_testSuccess ? AppColors.success : AppColors.error).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (_testSuccess ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _testSuccess ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: _testSuccess ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _testResult!,
              style: TextStyle(
                color: _testSuccess ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchTestmail() async {
    final uri = Uri.parse('https://testmail.app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
