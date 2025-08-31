import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_control_provider.dart';

class VoiceControlWidget extends StatelessWidget {
  const VoiceControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceControlProvider>(
      builder: (context, voiceProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice Control Button
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(16),
              child: FloatingActionButton(
                onPressed: voiceProvider.isListening
                    ? () => voiceProvider.stopListening()
                    : () => voiceProvider.startListening(),
                backgroundColor: voiceProvider.isListening
                    ? Colors.red.shade400
                    : Colors.blue.shade400,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: voiceProvider.isListening
                      ? const Icon(
                          Icons.mic_off,
                          key: ValueKey('mic_off'),
                          size: 32,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.mic,
                          key: ValueKey('mic_on'),
                          size: 32,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            
            // Status Text
            if (voiceProvider.isListening)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Listening...',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Last Command and Status
            if (voiceProvider.lastCommand.isNotEmpty || voiceProvider.lastError != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: voiceProvider.lastError != null
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: voiceProvider.lastError != null
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (voiceProvider.lastCommand.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '\"${voiceProvider.lastCommand}\"',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (voiceProvider.lastCommand.isNotEmpty &&
                        (voiceProvider.lastStatus.isNotEmpty || voiceProvider.lastError != null))
                      const SizedBox(height: 8),
                    if (voiceProvider.lastError != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              voiceProvider.lastError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (voiceProvider.lastError == null && voiceProvider.lastStatus.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              voiceProvider.lastStatus,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class VoiceControlFAB extends StatelessWidget {
  const VoiceControlFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceControlProvider>(
      builder: (context, voiceProvider, child) {
        return FloatingActionButton(
          onPressed: voiceProvider.isListening
              ? () => voiceProvider.stopListening()
              : () => voiceProvider.startListening(),
          backgroundColor: voiceProvider.isListening
              ? Colors.red.shade400
              : Colors.blue.shade400,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: voiceProvider.isListening
                ? const Icon(
                    Icons.mic_off,
                    key: ValueKey('mic_off'),
                    color: Colors.white,
                  )
                : const Icon(
                    Icons.mic,
                    key: ValueKey('mic_on'),
                    color: Colors.white,
                  ),
          ),
        );
      },
    );
  }
}

class VoiceControlHelpDialog extends StatelessWidget {
  const VoiceControlHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Voice Commands'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Train Control:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• "Train 101 forward fast"'),
            Text('• "Train red backward slow"'),
            Text('• "Train blue stop"'),
            Text('• "Train first forward medium"'),
            Text('• "Passenger train faster"'),
            Text('• "Train 101 slower"'),
            SizedBox(height: 16),
            Text(
              'Switch Control:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• "Switch 1 straight"'),
            Text('• "Switch 2 diverging"'),
            Text('• "Switch 1 left"'),
            Text('• "Switch 2 right"'),
            SizedBox(height: 16),
            Text(
              'Self Drive:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• "Train 101 self drive on"'),
            Text('• "Train blue self drive off"'),
            SizedBox(height: 16),
            Text(
              'Emergency:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• "Stop all trains"'),
            Text('• "Emergency stop"'),
            SizedBox(height: 16),
            Text(
              'Speed Options:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('slow, medium, fast, full, 10-100'),
            Text('faster (+10), slower (-10)'),
            SizedBox(height: 16),
            Text(
              'Train Names:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('red (101), blue (102), first (101), second (102)'),
            Text('main (101), freight (102), passenger (101), cargo (102)'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}