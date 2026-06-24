import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final file = provider.selectedFile;
        
        if (file == null) {
          return const Scaffold(
            body: Center(child: Text('No file selected')),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface.withOpacity(0.9),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => provider.setActiveView(ActiveView.dashboard),
            ),
            title: Text(
              file.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => provider.setActiveView(
                  ActiveView.editor,
                  fileId: file.id,
                ),
              ),
              IconButton(
                icon: Icon(
                  file.isFavorite ? Icons.star : Icons.star_outline,
                  color: file.isFavorite ? colorScheme.primary : null,
                ),
                onPressed: () => provider.toggleFavorite(file.id),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document share link copied!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: MarkdownBody(
              data: file.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                h2: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                h3: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
                p: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
                code: TextStyle(
                  backgroundColor: colorScheme.surfaceVariant,
                  color: colorScheme.secondary,
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                blockquote: TextStyle(
                  color: colorScheme.onPrimaryFixedVariant,
                  fontStyle: FontStyle.italic,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: colorScheme.primaryFixed.withOpacity(0.2),
                  border: Border(
                    left: BorderSide(
                      color: colorScheme.primary,
                      width: 4,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                checkbox: TextStyle(color: colorScheme.primary),
                listBullet: TextStyle(color: colorScheme.primary),
              ),
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => provider.setActiveView(
              ActiveView.editor,
              fileId: file.id,
            ),
            tooltip: 'Switch to Editor',
            child: const Icon(Icons.edit_note),
          ),
        );
      },
    );
  }
}
