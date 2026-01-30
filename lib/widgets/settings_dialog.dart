import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../services/lego-webservice.dart';

/// Dialog for configuring backend server settings
class SettingsDialog extends StatefulWidget {
  final SettingsService settingsService;

  const SettingsDialog({
    super.key,
    required this.settingsService,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _apiKeyController;

  bool _isTesting = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.settingsService.getHost());
    _portController = TextEditingController(text: widget.settingsService.getPort().toString());
    _apiKeyController = TextEditingController(text: widget.settingsService.getApiKey() ?? '');
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    // Validate first
    if (!SettingsService.isValidHost(_hostController.text)) {
      setState(() => _testResult = '✗ Invalid host format');
      return;
    }

    final port = int.tryParse(_portController.text);
    if (port == null || !SettingsService.isValidPort(port)) {
      setState(() => _testResult = '✗ Invalid port (must be 1-65535)');
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final testUrl = SettingsService.constructUrl(_hostController.text, port);
      final apiKey = _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null;

      // Use static method - doesn't modify singleton
      final status = await TrainWebService.testConnection(
        baseUrl: testUrl,
        apiKey: apiKey,
      );

      setState(() {
        _testResult = '✓ Connected! Found ${status.connectedTrains} trains, ${status.connectedSwitches} switches';
      });
    } catch (e) {
      setState(() {
        _testResult = '✗ Connection failed: ${e.toString()}';
      });
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _saveSettings() async {
    // Validate inputs
    if (!SettingsService.isValidHost(_hostController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid host format')),
        );
      }
      return;
    }

    final port = int.tryParse(_portController.text);
    if (port == null || !SettingsService.isValidPort(port)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Port must be between 1 and 65535')),
        );
      }
      return;
    }

    // Save to SharedPreferences
    await widget.settingsService.saveSettings(
      host: _hostController.text,
      port: port,
      apiKey: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
    );

    // Reconfigure singleton
    final webService = TrainWebService();
    webService.configure(
      customBaseUrl: SettingsService.constructUrl(_hostController.text, port),
      apiKey: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
    );

    if (mounted) {
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved. Connecting to new server...')),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    await widget.settingsService.resetToDefaults();

    setState(() {
      _hostController.text = widget.settingsService.getHost();
      _portController.text = widget.settingsService.getPort().toString();
      _apiKeyController.text = widget.settingsService.getApiKey() ?? '';
      _testResult = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset to default settings')),
      );
    }
  }

  Widget _buildTestResult() {
    if (_isTesting) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Testing connection...'),
        ],
      );
    }

    if (_testResult != null) {
      final isSuccess = _testResult!.startsWith('✓');
      return Text(
        _testResult!,
        style: TextStyle(
          color: isSuccess ? Colors.green : Colors.red,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Server Settings'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Host',
                  hintText: '192.168.86.39 or localhost',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: '8000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key (optional)',
                  hintText: 'Enter API key if required',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: const Icon(Icons.wifi_find),
                label: const Text('Test Connection'),
              ),
              const SizedBox(height: 12),
              _buildTestResult(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetToDefaults,
          child: const Text('Reset to Default'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
