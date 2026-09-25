import 'package:flutter/material.dart';

import '../../services/recipe_backup_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  int _modifiedRecipeCount = 0;

  bool _loading = true;
  bool _exporting = false;
  bool _importing = false;
  bool _resetting = false;

  @override
  void initState() {
    super.initState();

    _loadCount();
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  Future<void> _loadCount() async {
    try {
      final count = await RecipeBackupService.getModifiedRecipeCount();

      if (!mounted) {
        return;
      }

      setState(() {
        _modifiedRecipeCount = count;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    }
  }

  // ==========================================================
  // EXPORT
  // ==========================================================

  Future<void> _exportBackup() async {
    if (_isBusy) {
      return;
    }

    if (_modifiedRecipeCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no locally modified recipes to back up.'),
        ),
      );

      return;
    }

    setState(() {
      _exporting = true;
    });

    try {
      await RecipeBackupService.exportBackup();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe backup exported successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to export backup: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  // ==========================================================
  // IMPORT
  // ==========================================================

  Future<void> _importBackup() async {
    if (_isBusy) {
      return;
    }

    final shouldRestore = await _showRestoreConfirmation();

    if (!shouldRestore || !mounted) {
      return;
    }

    setState(() {
      _importing = true;
    });

    try {
      final count = await RecipeBackupService.importBackup();

      if (!mounted || count == null) {
        return;
      }

      await _loadCount();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$count recipe'
            '${count == 1 ? '' : 's'} restored successfully.',
          ),
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid backup: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to restore backup: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _importing = false;
        });
      }
    }
  }

  // ==========================================================
  // RESET LOCAL CHANGES
  // ==========================================================

  Future<void> _resetLocalChanges() async {
    if (_isBusy) {
      return;
    }

    if (_modifiedRecipeCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no local recipe changes to reset.'),
        ),
      );

      return;
    }

    final confirmed = await _showResetConfirmation();

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _resetting = true;
    });

    try {
      await RecipeBackupService.clearLocalRecipes();

      await _loadCount();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local recipe changes have been reset.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to reset local changes: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _resetting = false;
        });
      }
    }
  }

  // ==========================================================
  // RESTORE CONFIRMATION
  // ==========================================================

  Future<bool> _showRestoreConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore Recipe Backup?'),
          content: const Text(
            'Restoring a backup will replace all '
            'currently saved local recipe changes.\n\n'
            'Your bundled recipe JSON files will not '
            'be changed.\n\n'
            'Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ==========================================================
  // RESET CONFIRMATION
  // ==========================================================

  Future<bool> _showResetConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Local Changes?'),
          content: Text(
            'This will remove all '
            '$_modifiedRecipeCount local recipe '
            'change${_modifiedRecipeCount == 1 ? '' : 's'}.\n\n'
            'The original bundled recipes will become '
            'active again.\n\n'
            'This cannot be undone unless you have '
            'a backup.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ==========================================================
  // BUSY STATE
  // ==========================================================

  bool get _isBusy {
    return _exporting || _importing || _resetting;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====================================================
          // STATUS CARD
          // ====================================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.backup_outlined, size: 40),

                  const SizedBox(height: 16),

                  const Text(
                    'Recipe Backup',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Back up and restore your locally '
                    'edited recipes.',
                  ),

                  const SizedBox(height: 20),

                  if (_loading)
                    const LinearProgressIndicator()
                  else
                    Text(
                      '$_modifiedRecipeCount '
                      'modified recipe'
                      '${_modifiedRecipeCount == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ====================================================
          // EXPORT
          // ====================================================
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Export Recipe Backup'),
              subtitle: const Text('Save edited recipes as a JSON file.'),
              trailing: _exporting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isBusy ? null : _exportBackup,
            ),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // IMPORT
          // ====================================================
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text('Import Recipe Backup'),
              subtitle: const Text('Restore recipes from a JSON backup.'),
              trailing: _importing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isBusy ? null : _importBackup,
            ),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // RESET
          // ====================================================
          Card(
            child: ListTile(
              leading: Icon(
                Icons.restore_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Reset Local Changes'),
              subtitle: const Text(
                'Return recipes to their original bundled versions.',
              ),
              trailing: _resetting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isBusy ? null : _resetLocalChanges,
            ),
          ),

          const SizedBox(height: 24),

          // ====================================================
          // INFORMATION
          // ====================================================
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Resetting local changes does not '
                      'delete or modify the original recipe '
                      'JSON files included with the app.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
