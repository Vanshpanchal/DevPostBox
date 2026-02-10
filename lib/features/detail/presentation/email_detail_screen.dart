/// Email Detail Screen
/// Modern 2026 design with attachment support and OTP extraction
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../inbox/domain/test_mail.dart';
import '../../../core/utils/otp_extractor.dart';

class EmailDetailScreen extends StatefulWidget {
  final TestMail email;

  const EmailDetailScreen({super.key, required this.email});

  @override
  State<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends State<EmailDetailScreen> {
  String? _detectedOtp;

  @override
  void initState() {
    super.initState();
    _detectOtp();
  }

  void _detectOtp() {
    final content = widget.email.text.isNotEmpty ? widget.email.text : widget.email.html;
    setState(() {
      _detectedOtp = OtpExtractor.extract(content);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Force light mode logic as per app setting
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.textPrimaryLight,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.share_outlined,
                size: 20,
                color: AppColors.textPrimaryLight,
              ),
            ),
            onPressed: () => _shareEmail(context),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email header card
              _buildHeaderCard(context),
  
              const SizedBox(height: 16),
  
              // OTP detection
              if (_detectedOtp != null) _buildOtpSection(context, _detectedOtp!),
  
              // Attachments section
              if (widget.email.hasAttachments) _buildAttachmentsSection(context),
  
              // Email body card
              _buildBodyCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Text(
            widget.email.subject,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),

          // Sender info row
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.email.initials,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Sender details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.email.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email.fromAddress,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Meta info (Time & To)
          Row(
            children: [
              _buildMetaChip(
                context,
                Icons.schedule,
                DateFormat('MMM d, yyyy • h:mm a').format(widget.email.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetaChip(
                  context,
                  Icons.alternate_email,
                  'To: ${widget.email.to}',
                ),
              ),
            ],
          ),

          // Tag
          if (widget.email.tag.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.label_outline,
                    size: 16,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.email.tag,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpSection(BuildContext context, String otpCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Material(
        color: AppColors.secondary, // Yellow background for high visibility
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: AppColors.secondary.withValues(alpha: 0.3),
        child: InkWell(
          onTap: () => _copyToClipboard(context, otpCode),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      'VERIFICATION CODE',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  otpCode,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'JetBrains Mono',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.black,
                        fontSize: 32,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to Copy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_file,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attachments (${widget.email.attachmentCount})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Attachment list
          ...widget.email.attachments.map((attachment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _downloadAndOpenAttachment(context, attachment),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: Row(
                      children: [
                        // File type icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getFileColor(attachment.extension)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.insert_drive_file,
                              color: _getFileColor(attachment.extension),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // File info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attachment.filename,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                attachment.formattedSize,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Download icon
                        const Icon(
                          Icons.download_rounded,
                          size: 24,
                          color: AppColors.primaryLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBodyCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Message',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Email body
          if (widget.email.hasHtml)
            Html(
              data: widget.email.html,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: AppColors.textPrimaryLight,
                  fontFamily: 'Inter',
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.5),
                ),
                'p': Style(
                  lineHeight: LineHeight(1.6),
                  margin: Margins.only(bottom: 12),
                ),
                'a': Style(
                  color: AppColors.primaryLight,
                  textDecoration: TextDecoration.none,
                  fontWeight: FontWeight.w600,
                ),
                'img': Style(
                  display: Display.block,
                  width: Width(100, Unit.percent),
                  margin: Margins.symmetric(vertical: 16),
                ),
                'blockquote': Style(
                  margin: Margins.symmetric(horizontal: 0, vertical: 12),
                  padding: HtmlPaddings.only(left: 16),
                  border: const Border(
                    left: BorderSide(color: AppColors.secondary, width: 4),
                  ),
                  backgroundColor: AppColors.backgroundLight,
                ),
                'code': Style(
                  backgroundColor: Colors.grey.shade100,
                  padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
                  fontFamily: 'JetBrains Mono',
                ),
                'pre': Style(
                  backgroundColor: Colors.grey.shade100,
                  padding: HtmlPaddings.all(12),
                  fontFamily: 'JetBrains Mono',
                  display: Display.block,
                  whiteSpace: WhiteSpace.pre,
                ),
              },
              onLinkTap: (url, _, __) {
                if (url != null) _showLinkDialog(context, url);
              },
            )
          else
            SelectableText(
              widget.email.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppColors.textPrimaryLight,
              ),
            ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareEmail(BuildContext context) {
    final shareText = '''
Subject: ${widget.email.subject}
From: ${widget.email.from}
Date: ${DateFormat('MMM d, yyyy • h:mm a').format(widget.email.createdAt)}

${widget.email.text}
''';

    Share.share(shareText, subject: widget.email.subject);
  }

  Future<void> _downloadAndOpenAttachment(
      BuildContext context, EmailAttachment attachment) async {
    // Show download dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Downloading attachment...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${attachment.filename}';

      // Download file
      await dio.download(attachment.downloadUrl, filePath);

      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        
        // Open file using open_filex
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception(result.message);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'zip':
      case 'rar':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showLinkDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Open Link?'),
        content: Text(
          url,
          style: const TextStyle(
            color: AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, url);
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }
}
