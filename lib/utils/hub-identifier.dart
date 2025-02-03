// hub_identifier.dart
import 'package:universal_ble/universal_ble.dart';

class HubIdentifier {
  static bool isLegoHub(BleDevice device) {
    final dataList = device.manufacturerDataList;
    if (dataList == null || dataList.isEmpty) {
      return false;
    }

    final manufacturerData = dataList[0];
    final dataString = manufacturerData.toString();

    // Parse out manufacturer ID
    if (!dataString.contains('0x0397')) {
      return false;
    }

    // Parse out the bytes array
    final startBracket = dataString.indexOf('[');
    final endBracket = dataString.indexOf(']');
    if (startBracket == -1 || endBracket == -1) return false;

    final bytesString = dataString.substring(startBracket + 1, endBracket);
    final bytes = bytesString.split(',').map((s) => int.parse(s.trim())).toList();

    // Debug print all bytes
    for (int i = 0; i < bytes.length; i++) {
      print('Byte $i: ${bytes[i]} (0x${bytes[i].toRadixString(16).padLeft(2, '0')})');
    }

    if (bytes.length >= 5) {
      final byte4 = bytes[4];  // Try byte 4 instead of 5
      final maskedByte = byte4 & 0xE0;  // Apply mask to get top 3 bits
      final systemType = maskedByte >> 5;  // Shift right by 5
      final deviceNumber = byte4 & 0x1F;  // Get bottom 5 bits

      print('Using byte 4:');
      print('Raw byte: $byte4 (0x${byte4.toRadixString(16).padLeft(2, '0')})');
      print('After mask (0xE0): $maskedByte');
      print('System type: $systemType');
      print('Device number: $deviceNumber');

      // Accept system type 2 (LEGO System) or 1 (LEGO Duplo)
      return systemType >= 1 && systemType <= 2;
    }

    return false;
  }

  static String getHubType(BleDevice device) {
    final dataList = device.manufacturerDataList;
    if (dataList == null || dataList.isEmpty) {
      return 'Unknown Hub';
    }

    final manufacturerData = dataList[0];
    final dataString = manufacturerData.toString();

    // Parse bytes array
    final startBracket = dataString.indexOf('[');
    final endBracket = dataString.indexOf(']');
    if (startBracket == -1 || endBracket == -1) return 'Unknown Hub';

    final bytesString = dataString.substring(startBracket + 1, endBracket);
    final bytes = bytesString.split(',').map((s) => int.parse(s.trim())).toList();

    if (bytes.length >= 5) {
      final deviceNumber = bytes[4] & 0x1F;  // Get bottom 5 bits of byte 4

      switch (deviceNumber) {
        case 0x00:
          return 'Boost Hub';
        case 0x01:
          return 'Technic Hub';
        case 0x02:
          return 'Remote Control';
        case 0x03:
          return 'Train Hub';
        default:
          return 'Unknown Hub Type (0x${deviceNumber.toRadixString(16)})';
      }
    }

    return 'Unknown Hub';
  }
}